import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../search_post/users_specific_posts.dart';
import '../widgets/ssbadge.dart';
import 'SubComment.dart';


class CommentItem extends StatelessWidget {

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
  String? image;
  Timestamp? timestamp;
  String activityId = const Uuid().v4();
  List<String>? likes = List.empty(growable: true);
  List<String>? subCommentsIds = List.empty(growable: true);
  String? originalCommentId;

  CommentItem({super.key, this.userName, this.userId,
    this.comment, this.timestamp, this.userImage,
    this.commentId, this.commenterId, required this.postId,
    this.image, this.subCommentsIds, this.likes
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

  factory CommentItem.fromDocument(DocumentSnapshot doc){
    return CommentItem(
      userName: doc.data().toString().contains('commenterName') ? doc.get(
          'commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get(
          'commenterId') : '',
      comment: doc.data().toString().contains('comment')
          ? doc.get('comment') : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get(
          'timestamp') : '',
      userImage: doc.data().toString().contains('commenterImage') ? doc.get(
          'commenterImage') : '',
      commentId: doc.data().toString().contains('commentId') ? doc.get(
          'commentId') : '',
      subCommentsIds: doc.data().toString().contains('subCommentIds') ? List
          .from(doc.get('subCommentIds')) : List.empty(),
      likes: doc.data().toString().contains('likes') ? List
          .from(doc.get('likes')) : List.empty(growable: true),
      postId: doc.data().toString().contains('postId') ? doc.get(
          'postId') : '',
    );
  }

  showSubcomments(BuildContext context){
    CommentItem commentItem = CommentItem(userName: userName,
      userId: userId, comment: comment, timestamp: timestamp,
      userImage: userImage, commentId: commentId,
      subCommentsIds: subCommentsIds, likes: likes,
      postId: postId, image: image, commenterId: commenterId,
    );

    Navigator.push(context, MaterialPageRoute(
        builder: (_) => SubComment(commentItem: commentItem)));
  }

  @override
  Widget build(BuildContext context) {
    likerUserId = _auth.currentUser?.uid;
    likesCount = likes?.length ?? 0;

    var likeBadgeView = SSBadge(top: 0, right: 2,
        value: likesCount.toString(),
        child: IconButton(
            icon: const Icon(Icons.thumb_up_sharp), onPressed: () {
          handleLikeComment();
        }));

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment!),
          subtitle: Text(userName!),
          trailing: Container(
            child: likeBadgeView,
          ),
          onTap: () {
            showSubcomments(context);
          },
          leading: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
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
