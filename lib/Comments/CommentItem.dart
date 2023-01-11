import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../search_post/users_specific_posts.dart';
import 'SubComment.dart';

class CommentItem extends StatelessWidget {

  TextEditingController commentController1 = TextEditingController();

  final firebase = FirebaseFirestore.instance;

  String? userName;
  String? userImage;
  String? userId;
  String? comment;
  String? commentId;
  Timestamp? timestamp;
  List<String>? subCommentsIds = List.empty(growable: true);
  String? originalCommentId;

  CommentItem({super.key,
    this.userName,
    this.userId,
    this.comment,
    this.timestamp,
    this.userImage,
    this.commentId,
    this.subCommentsIds,
  });

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

  factory CommentItem.fromDocument(DocumentSnapshot doc){
    return CommentItem(
      userName: doc.data().toString().contains('commenterName') ? doc.get('commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get('commenterId') : '',
      comment: doc.data().toString().contains('comment') ? doc.get('comment') : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get('timestamp') : '',
      userImage: doc.data().toString().contains('commenterImage') ? doc.get('commenterImage') : '',
      commentId: doc.data().toString().contains('commentId') ? doc.get('commentId') : '',
      subCommentsIds: doc.data().toString().contains('subCommentIds') ? List.from(doc.get('subCommentIds')) : List.empty(),
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
          trailing: IconButton(icon: const Icon(Icons.arrow_drop_down), onPressed: () {
            if (subCommentsIds != null && subCommentsIds!.isNotEmpty){
              CommentItem commentItem = CommentItem(userName: userName, userId: userId,
                  comment: comment, timestamp: timestamp, userImage: userImage,
                  commentId: commentId, subCommentsIds: subCommentsIds);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SubComment(commentItem: commentItem)));
            }
            else {
              Fluttertoast.showToast(msg: 'No more comments under this');
            }
          }),
          onTap: (){
            displayAddCommentDialog(context);
          },
          leading:
          GestureDetector(
              onTap:(){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
                  userId:userId,
                  userName:userName,
                )));
              },
              child: CircleAvatar(
                radius:35,
                backgroundImage:  CachedNetworkImageProvider(userImage!),
              )
          ),
        ),
        const Divider(),
      ],
    );
  }
}