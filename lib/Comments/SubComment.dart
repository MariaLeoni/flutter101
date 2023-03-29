import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

import 'CommentItem.dart';

class SubComment extends StatefulWidget {

  CommentItem? commentItem;
  SubComment({super.key, this.commentItem});

  @override
  CommentState createState() => CommentState();
}


class CommentState extends State<SubComment> {
  String? postId;
  String? userId;
  String? myImage;
  String? myName;
  String? id;
  String commentId = const Uuid().v4();
  String? myUserId;
  String? description;
  int? downloads;
  String? postOwnerId;
  String? postOwnername;
  String? postOwnerImage;
  String? Image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController commentController = TextEditingController();
  String ActivityId = const Uuid().v4();
  List<String>? Likes = List.empty(growable: true);
  CommentState({
    String? postId,
    String? commentId,
    String? userId,
  });

  addCommentTaggingToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.commentItem!.commenterId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.commentItem!.commenterId)
          .collection('FeedItems').doc(ActivityId).set({
        "type": "comment reply",
        "name": myName,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": myImage,
        "postId": widget.commentItem!.postId,
        "Activity Id": ActivityId,
        "Image": Image,
        "timestamp": DateTime.now(),
        "commentData":  commentController.text,
        "description": description,
        "downloads": downloads,
        "likes": Likes,
        "postOwnerId": postOwnerId,
        "postOwnerImage": postOwnerImage,
        "postOwnername": postOwnername,
        'Read Status': false
      });
    }
    commentController.clear();
  }

  buildComments(){
    final firebaseCollection = FirebaseFirestore.instance.collection('comment');

    return StreamBuilder(
      stream: firebaseCollection.where(FieldPath.documentId,
          whereIn: widget.commentItem!.subCommentsIds!).snapshots(),
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

  addComment() {
    FirebaseFirestore.instance.collection('comment').doc(commentId).set({
      "comment": commentController.text,
      "commenterImage": myImage,
      "commenterName" : myName,
      "timestamp": DateTime.now(),
      "commenterId": id,
      "originalCommentId": widget.commentItem?.commentId,
      "commentId": commentId,
      'subCommentIds': <String>[],
     // "postId": widget.commentItem!.postId,

    });
    addCommentTaggingToActivityFeed();
    commentController.clear();
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(myUserId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      id = snapshot.get('id');
    });
  }

  void readUserInfo2() async {
    FirebaseFirestore.instance.collection('wallpaper').doc(widget.commentItem!.postId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      description = snapshot.get('description');
      Likes = snapshot.get('likes');
      downloads = snapshot.get('downloads');
      postOwnerId = snapshot.get('id');
      postOwnername = snapshot.get('name');
      postOwnerImage = snapshot.get('userImage');
      Image = snapshot.get('Image');
    });
  }

  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;

    readUserInfo();
    readUserInfo2();
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
          Column(children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
              title: Text(widget.commentItem!.comment!),
              subtitle: Text(widget.commentItem!.userName!),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.commentItem!.userImage!),
              ),
            )
          ]
          ),
          const Divider(),
          Expanded(child: buildComments()),
          const Divider(),
          ListTile(
              title: TextFormField(
                controller: commentController,
                decoration: const InputDecoration(labelText: "Write a comment.."),
              ),
              trailing: OutlinedButton(
                onPressed: addComment,
                child: const Text("Post"),
              )
          ),
        ],
      ),
    );
  }
}