import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../search_post/users_specific_posts.dart';
import 'SubComment.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class CommentItem extends StatelessWidget {

  TextEditingController commentController1 = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;

  int? total;
  int likesCount = 0;
  String? likerUserId;
  String? userName;
  String? userImage;
  String? userId;
  String? comment;
  String? commentId;
  String? commenterId;
  String? postImage;
  String? postId;
  String? Image;
  Timestamp? timestamp;
  String ActivityId = const Uuid().v4();
  List<String>? likes = List.empty(growable: true);
  List<String>? subCommentsIds = List.empty(growable: true);
  String? originalCommentId;

  CommentItem({super.key,
    this.userName,
    this.userId,
    this.comment,
    this.timestamp,
    this.userImage,
    this.commentId,
    this.commenterId,
    this.postId,
    this.Image,
    this.subCommentsIds,
    this.likes
  });

  handleLikeComment() {
    if (likes != null && likes!.contains(likerUserId)) {
      Fluttertoast.showToast(msg: "You unliked this comment!");
      likes!.remove(likerUserId);
    }
    else {
      Fluttertoast.showToast(msg: "You liked this comment!");
      likes!.add(likerUserId!);
    }

    FirebaseFirestore.instance.collection('comment').doc(commentId)
        .update({'likes': likes!,
    }).then((value) {
      likesCount = (likes?.length ?? 0);
    });
  }

  // void readUserInfo() async {
  //   FirebaseFirestore.instance.collection('users').doc(myUserId)
  //       .get().then<dynamic>((DocumentSnapshot snapshot) {
  //     myImage = snapshot.get('userImage');
  //     myName = snapshot.get('name');
  //     id = snapshot.get('id');
  //   });
  // }
  // addCommentTaggingToActivityFeed() {
  //   bool isNotPostOwner = _auth.currentUser!.uid != commenterId;
  //   if (isNotPostOwner) {
  //     FirebaseFirestore.instance.collection('Activity Feed').doc(commenterId)
  //         .collection('FeedItems').doc(ActivityId).set({
  //       "type": "comment reply",
  //       "name": myName,
  //       "userId": _auth.currentUser!.uid,
  //       "userProfileImage": myImage,
  //       "postId": postId,
  //       "Activity Id": ActivityId,
  //       "Image": Image,
  //       "timestamp": DateTime.now(),
  //       "commentData":  commentController1.text,
  //       "description": description,
  //       "downloads": downloads,
  //       "likes": Likes,
  //       "postOwnerId": postOwnerId,
  //       "postOwnerImage": postOwnerImage,
  //       "postOwnername": postOwnername,
  //       'Read Status': false
  //     });
  //   }
  //   commentController.clear();
  // }

  addComment() {
    originalCommentId = commentId;
    String replyCommentId = const Uuid().v4();

    firebase.collection('comment').doc(replyCommentId).set({
      "comment": commentController1.text,
      "commenterImage": userImage,
      "commenterName": userName,
      "timestamp": DateTime.now(),
      "commenterId": userId,
      "likes": <String>[],
      "originalCommentId": originalCommentId,
      "commentId": replyCommentId,
      "postId": postId,
      'subCommentIds': <String>[],
    });

    firebase.collection('comment').doc(originalCommentId)
        .update({
      'subCommentIds': FieldValue.arrayUnion(
          List<String>.filled(1, replyCommentId)),
    });

    commentController1.clear();
  }

  factory CommentItem.fromDocument(DocumentSnapshot doc){
    return CommentItem(
      userName: doc.data().toString().contains('commenterName') ? doc.get(
          'commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get(
          'commenterId') : '',
      comment: doc.data().toString().contains('comment')
          ? doc.get('comment')
          : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get(
          'timestamp') : '',
      userImage: doc.data().toString().contains('commenterImage') ? doc.get(
          'commenterImage') : '',
      commentId: doc.data().toString().contains('commentId') ? doc.get(
          'commentId') : '',
      subCommentsIds: doc.data().toString().contains('subCommentIds') ? List
          .from(doc.get('subCommentIds')) : List.empty(),
      likes: doc.data().toString().contains('likes') ? List
          .from(doc.get('likes')) : List.empty(),
      postId: doc.data().toString().contains('postId') ? doc.get(
          'postId') : '',
      // Image: doc.data().toString().contains('Image') ? doc.get(
      //     'Image') : '',
      // commenterId: doc.data().toString().contains('commenterId') ? doc.get(
      //     'commenterId') : '',
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
    likerUserId = _auth.currentUser?.uid;
    likesCount = (likes?.length ?? 0);

    var likeText = Text(likesCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.black, fontWeight: FontWeight.bold));

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment!),
          subtitle: Text(userName!),
          trailing: Wrap(
            spacing: 2, // space between two icons
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.arrow_forward), onPressed: () {
                if (subCommentsIds != null && subCommentsIds!.isNotEmpty) {
                  CommentItem commentItem = CommentItem(userName: userName,
                    userId: userId, comment: comment, timestamp: timestamp,
                    userImage: userImage, commentId: commentId,
                    subCommentsIds: subCommentsIds, likes: likes,
                  postId: postId, Image: Image, commenterId: commenterId,
                  );

                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SubComment(commentItem: commentItem)));
                }
                else {
                  Fluttertoast.showToast(msg: 'No more comments under this');
                }
              }),
              IconButton(icon: const Icon(Icons.thumb_up_sharp),
                  onPressed: () => handleLikeComment()),
              likeText,
            ],
          ),
          onTap: () {
            displayAddCommentDialog(context);
          },
          leading:
          GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
                  userId: userId, userName: userName,
                )));
              },
              child: CircleAvatar(
                radius: 35,
                backgroundImage: CachedNetworkImageProvider(userImage!),
              )
          ),
        ),
        const Divider(),
      ],
    );
  }
}
