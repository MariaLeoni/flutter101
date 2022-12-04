import 'package:flutter/material.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:sharedstudent1/owner_details/owner_details.dart';
class Comment extends StatefulWidget {
  final String id;
  final String userImage;
  final String Image;

  Comment({
    required this.id,
    required this.userImage,
    required this.Image,
  });

  @override
  State<Comment> createState() => CommentState(
    id: this.id,
    userImage: this.userImage,
    Image: this.Image,
  );
}

class CommentState extends State<Comment> {
  final String id;
  final String userImage;
  final String Image;

  CommentState({
    required this.id,
    required this.userImage,
    required this.Image,
  });

  TextEditingController commentController = TextEditingController();

  buildComments() {
    return StreamBuilder(stream: commentsRef.doc(id).collection('comments')
        .orderBy("timestamp", descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
        }
    );
  }

  addComment() {
    commentsRef
        .doc(id)
        .collection("comments")
        .add({
      "username": name,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": avatarurl,
      "userId": id,
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: "Comments"),
        body: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            Divider(),
            ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: "Write a comment.."),
                ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  borderSide: BorderSide.none,
                  child: Text("Post"),
                )
            ),
          ],
        )
    );
  }

  circularProgress() {}
}

header(BuildContext context, {required String titleText}) {}

class Comments extends StatelessWidget{
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comments({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comments.fromDocument(DocumentSnapshot doc){
    return Comments(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage:
            CachedNetworkImageProvider
              (avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}

