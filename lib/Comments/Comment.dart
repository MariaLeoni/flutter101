import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/Comments/Commentx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

class Comment extends StatefulWidget {

  String? userId;
  String? postId;
  String? docId;

  Comment({super.key, this.userId, this.postId,
    this.docId,});

  @override
  State<Comment> createState() => CommentState(
    postId: postId,
    userId: this.userId,);
}


class CommentState extends State<Comment> {
  String? postId;
  String? userId;
  String? myImage;
  String? myName;
  String? Id;
  String commentId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? myUserId;

  CommentState({
    String? postId,
    String? commentId,
    String? userId,
  });

  TextEditingController commentController = TextEditingController();


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
        List<Comments> comment = [];
        for (var doc in snapshot.data!.docs) {
          comment.add(Comments.fromDocument(doc));
        }
        return ListView(
          children: comment,
        );
      },
    );
  }

  addComment() {
    FirebaseFirestore.instance.collection('comment').doc(commentId).set({
      "comment": commentController.text,
      "commenterImage": myImage,
      "commenterName" : myName,
      "timestamp": DateTime.now(),
      "commenterId": Id,
      "originalCommentId": null,
      "commentId": commentId,
      "postId": widget.postId,
      'subCommentIds': <String>[],
    });
    commentController.clear();
  }

  void read_userInfo() async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      Id = snapshot.get('id');
    });
  }


  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    read_userInfo();
  }


  @override
  Widget build(BuildContext context) {


  //
  //   FirebaseFirestore.instance.collection('comment').where("commentId", isEqualTo: "bbcebf93-5adf-46eb-8a8f-2a1b55e78448")
  //       .update({'subCommentIds': "69009d20-c189-464d-9167-5ca1ffebcf39",
  //   });

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
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

class Comments extends StatelessWidget {
  String? userName;
  String? userImage;
  String? userId;
  String? comment;
  String? commentId;
  Timestamp? timestamp;
  String? originalCommentId;

  Comments({
    this.userName,
    this.userId,
    this.comment,
    this.timestamp,
    this.userImage,
    this.commentId,

  });
  TextEditingController commentController1 = TextEditingController();

  final firebase = FirebaseFirestore.instance;

  addComment() {
    originalCommentId = commentId;

    String replyCommentId = const Uuid().v4();

    firebase.collection('comment').doc(replyCommentId).set({
      "comment": commentController1.text,
      "commenterImage": userImage,
      "commenterName" : userName,
      "timestamp": DateTime.now(),
      "commenterId": userId,

      "originalCommentId": originalCommentId,
      "commentId": replyCommentId,
      "postId": null,
      'subCommentIds': <String>[],
    });

    firebase.collection('comment').doc(originalCommentId)
        .update({'subCommentIds': FieldValue.arrayUnion(List<String>.filled(1, replyCommentId)),
    });

    commentController1.clear();
  }

  factory Comments.fromDocument(DocumentSnapshot doc){
    return Comments(
      userName: doc.data().toString().contains('commenterName') ? doc.get('commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get('commenterId') : '',
      comment: doc.data().toString().contains('comment') ? doc.get('comment') : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get('timestamp') : '',
      userImage: doc.data().toString().contains('commenterImage') ? doc.get('commenterImage') : '',
      commentId: doc.data().toString().contains('commentId') ? doc.get('commentId') : '',
    );
  }

  Future<void> displayAddCommentDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to comment'),
          content: TextField(
            controller: commentController1,
            decoration: const InputDecoration(hintText: "Add your comment..."),
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: const Text('OK'),
              onPressed: () {
                addComment();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment!),
          subtitle: Text(userName!),
          trailing: const Icon
            (Icons.arrow_drop_down),
          onTap: (){
            print("Original Comment Id $originalCommentId and commentId $commentId");
            displayAddCommentDialog(context);
          },
          leading: CircleAvatar(
            backgroundImage:
            CachedNetworkImageProvider
              (userImage!),
          ),
          // subtitle: Text(timeago.format(timestamp?.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}






