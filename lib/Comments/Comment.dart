import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:sharedstudent1/Comments/CommentItem.dart';

import '../notification/notification.dart';
import '../notification/server.dart';
import '../returnusers.dart';

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
  List<String>? users = List.empty(growable:true);
  Comment({super.key, this.userId, this.postId,
    this.docId,this.Image, this.likes, this.description,this.downloads, this.postOwnerImg, this.postOwnername, this.users,});

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
  List<String>
      words = [];
  String str = '';
  List<String> coments=[];
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

  showProfile(String s) {
    showDialog(
        context: context,
        builder: (con) =>
            AlertDialog(
                title: Text('Profile of $s'),
                content: Text('Show the user profile !')
            ));
  }
  buildUsers(){
  // final firebaseCollection = FirebaseFirestore.instance.collection('users');
  return StreamBuilder(
  stream: FirebaseFirestore.instance.collection('users').snapshots(),
  builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
  if(snapshot.connectionState == ConnectionState.waiting ) {
  return const Center(child: CircularProgressIndicator(),);
  }
  else if (snapshot.connectionState == ConnectionState.active) {
  if(snapshot.data!.docs.isNotEmpty){
  {
  List<UsersModel> users = [];
  for (var doc in snapshot.data!.docs) {
  users.add(UsersModel.fromDocument(doc));
  }
  return Comment(
    users: [],

  );

  }
  }
  else if (snapshot.data!.docs.isEmpty) {
  return const Center(
  child: Text("This user has no followers ",
  style: TextStyle(fontSize: 20),)
  );
  }
  }
  return const Center(
  child: Text(
  'Something went wrong',
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
  ),
  );
  }
  // builder: (context, snapshot) {
  //   if (snapshot.hasError) {
  //     return const Text('Something went wrong');
  //   }
  //   if (snapshot.connectionState == ConnectionState.waiting) {
  //     return const Center(child: CircularProgressIndicator(),);
  //   }
  //   List<FollowerModel> followers = [];
  //   for (var doc in snapshot.data!.docs) {
  //     followers.add(FollowerModel.fromDocument(doc));
  //   }
  //   return ListView(
  //     children: followers,
  //   );
  //
  //   }
  );}
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
                    onChanged: (val) {
                      setState(() {
                        words = val.split(' ');
                        str = words.length > 0 &&
                            words[words.length - 1].startsWith('@')
                            ? words[words.length - 1]
                            : '';
                      });
                    }

                ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  //  borderSide: BorderSide.none,
                  child: const Text("Post"),
                )
            ),
            str.length > 1
                ? ListView(


                shrinkWrap: true,
                children: widget.users!.map((s) {
                  if (('@' + s).contains(str))
                    return
                      ListTile(
                          title: Text(s, style: TextStyle(color: Colors.black),),
                          onTap: () {
                            String tmp = str.substring(1, str.length);
                            setState(() {
                              str = '';
                              commentController.text += s
                                  .substring(
                                  s.indexOf(tmp) + tmp.length, s.length)
                                  .replaceAll(' ', '_');
                            });
                          });
                  else
                    return SizedBox();
                }).toList()
            ) : SizedBox(),
            SizedBox(height: 25),
            coments.length > 0 ?
            ListView.builder(
              shrinkWrap: true,
              itemCount: coments.length,
              itemBuilder: (con, ind) {
                return Text.rich(
                  TextSpan(
                      text: '',
                      children: coments[ind].split(' ').map((w) {
                        return w.startsWith('@') && w.length > 1 ?
                        TextSpan(
                          text: ' ' + w,
                          style: TextStyle(color: Colors.blue),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () => showProfile(w),
                        ) : TextSpan(text: ' ' + w, style: TextStyle(
                            color: Colors.black));
                      }).toList()
                  ),
                );
              },
            ) : SizedBox()

          ],
        )
    );
  }
}