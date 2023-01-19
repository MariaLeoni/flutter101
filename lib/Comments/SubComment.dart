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
    });
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

  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    readUserInfo();
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