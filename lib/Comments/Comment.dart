import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:sharedstudent1/Comments/CommentItem.dart';

import '../notification/notification.dart';
import '../notification/server.dart';

class Comment extends StatefulWidget {

  String? userId;
  String? postId;
  String? docId;
  String? Image;
  String? postOwnerImg;
  String? postOwnername;
  List<String>? likes = List.empty(growable: true);
  String? description;
  int? downloads;
  Comment({super.key, this.userId, this.postId,
    this.docId,this.Image, this.likes, this.description, this.downloads, this.postOwnerImg, this.postOwnername});

  @override
  State<Comment> createState() => CommentState();
}


class CommentState extends State<Comment> {
  String? postId;
  String? userId;
  String? myImage;
  String? myName;
  String? id;
  String? tokens;
  String commentId = const Uuid().v4();
  String? myUserId;
  NotificationManager? notificationManager;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController commentController = TextEditingController();

  CommentState({
    String? postId,
    String? commentId,
    String? userId,

  });

  buildComments(){
    final firebaseCollection = FirebaseFirestore.instance.collection('comment');

    return StreamBuilder(
      stream: firebaseCollection.where("postId", isEqualTo: widget.postId).snapshots(),
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        List<CommentItem> comments = [];
        for (var doc in snapshot.data!.docs) {
          comments.add(CommentItem.fromDocument(doc));
        }

        comments.sort((a,b) {
          var aTimeStamp = a.timestamp;
          var bTimeStamp = b.timestamp;
          return aTimeStamp!.compareTo(bTimeStamp!);
        });
        return ListView(children: comments);
      },
    );
  }
  void getDataFromDatabase2() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.docId)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        tokens = snapshot.data()!["devicetoken"];


      });
    }
    });
  }
  void sendNotification() {
    NotificationModel model = NotificationModel(title: myName,
        body: "Liked your comment", dataBody: widget.Image,
        //dataTitle: "Should be post description"
        );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }
  AddLikeToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.userId)
          .collection('FeedItems').add({
        "type": "comment",
        "name": myName,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": myImage,
        "postId": widget.postId,
        "Image": widget.Image,
        "timestamp": DateTime.now(),
        "commentData":  commentController.text,
        "description": widget.description,
         "downloads": widget.downloads,
         "likes": widget.likes,
        "postOwnerId": widget.userId,
        "postOwnerImage": widget.postOwnerImg,
         "postOwnername": widget.postOwnername,
        "likes": widget.likes,
        "downloads": widget.downloads,
          });
    }
  }
  addComment() {
    FirebaseFirestore.instance.collection('comment').doc(commentId).set({
      "comment": commentController.text,
      "commenterImage": myImage,
      "commenterName": myName,
      "timestamp": DateTime.now(),
      "commenterId": id,
      "originalCommentId": null,
      "commentId": commentId,
      "postId": widget.postId,
      'subCommentIds': <String>[],
      'likes': <String>[],
      'Image': widget.Image,
    });
    AddLikeToActivityFeed();
    sendNotification();
    commentController.clear();
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      id = snapshot.get('id');
    });
  }


  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    readUserInfo();
    getDataFromDatabase2();
    notificationManager = NotificationManager();
    notificationManager?.initServer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2],
              ),
            ),
          ),
          title: const Text("Comments"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            const Divider(),
            ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: "Write a comment.."),
                ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  //  borderSide: BorderSide.none,
                  child: const Text("Post"),
                )
            ),
          ],
        )
    );
  }
}