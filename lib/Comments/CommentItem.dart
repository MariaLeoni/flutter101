import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../misc/alertbox.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../search_post/users_specific_posts.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/ssbadge.dart';
import 'SubComment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  NotificationManager? notificationManager;
  int? total;
  int likesCount = 0;
  String? likerUserId;
  String? userName;
  String? userImage;
  String? userId;
  String? comment;
  String? commentId;
  String? postImage;
  String? postId;
  String? Image;
  String? myImage;
  String? myName;
  DateTime? timestamp = DateTime.now();
  String ActivityId = const Uuid().v4();
  List<String>? likes = List.empty(growable: true);
  List<String>? subCommentsIds = List.empty(growable: true);
  String? OriginalCommentId;
  String? OriginalCommenterId;
  String? postdescription;
  List<String>? postlikes = List.empty(growable:true);
  int? postdownloads;
  String? postOwnername;
  String? postOwnerId;
  String? postOwnerImage;
  String? tokens;
  String? token;
  String postType = "";

  CommentItem({super.key, required this.postType,this.userName, this.userId,
    this.comment, this.timestamp, this.userImage, this.commentId, this.OriginalCommentId,
    this.OriginalCommenterId, required this.postId, this.Image, this.subCommentsIds, this.likes,
    this.postdescription, this.postlikes,this.postdownloads,this.postOwnername, this.postOwnerId,
    this.postOwnerImage,this.tokens,
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
   AddLike();
  }

  AddLike(){
    bool isNotPostOwner = _auth.currentUser!.uid != userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(userId)
          .collection('FeedItems').doc(ActivityId)
          .set({
        "type": "likeComment",
        "name": myName,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": myImage,
        "postId": postId,
        "Activity Id": ActivityId,
        "Image": Image,
        "timestamp": DateTime.now(),
        "commentData": "",
        "downloads": postdownloads,
        "description": postdescription,
        "likes": postlikes,
        "postOwnerId": postOwnerId,
        "postOwnerImage": postOwnerImage,
        "postOwnername": postOwnername,
        "Read Status": false,
        "PostType": postType,

      });
    }
  sendNotification("liked your comment");

}
  // void sendNotification() {
  //   NotificationModel model = NotificationModel(title: myName,
  //     body: "Liked your comment", dataBody: Image,
  //     // dataTitle: "Should be post description"
  //   );
  //   String? token = tokens;
  //   notificationManager?.sendNotification(token!, model);
  // }
  void sendNotification(String action) {
    bool isNotPostOwner = token != tokens;
    if (isNotPostOwner) {
    NotificationModel model = NotificationModel(title: myName,
      body: action,
    );
    if (tokens != null) {
      notificationManager?.sendNotification(tokens!, model);
    }
  }}
  factory CommentItem.fromDocument(DocumentSnapshot doc){
    return CommentItem(
      userName: doc.data().toString().contains('commenterName') ? doc.get(
          'commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get(
          'commenterId') : '',
      comment: doc.data().toString().contains('comment')
          ? doc.get('comment') : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get(
          'timestamp').toDate() : '',
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
      Image: doc.data().toString().contains('Image') ? doc.get(
          'Image') : '',
      postdescription: doc.data().toString().contains('description') ? doc.get(
          'description') : '',
       postdownloads: doc.data().toString().contains('downloads') ? doc.get(
           'downloads') : '',
      postlikes: doc.data().toString().contains('postlikes') ? List
          .from(doc.get('postlikes')) : List.empty(growable: true),
      postOwnerId: doc.data().toString().contains('postOwnerId') ? doc.get(
          'postOwnerId') : '',
      postOwnerImage: doc.data().toString().contains('postOwnerImage') ? doc.get(
          'postOwnerImage') : '',
      postOwnername: doc.data().toString().contains('postOwnername') ? doc.get(
          'postOwnername') : '',
      postType: doc.data().toString().contains('postType') ? doc.get(
          'postType') : '',

    );
  }


  showSubcomments(BuildContext context){
    CommentItem commentItem = CommentItem(userName: userName,
      userId: userId, comment: comment, timestamp: timestamp,
      userImage: userImage, commentId: commentId,
      subCommentsIds: subCommentsIds, likes: likes,
      postId: postId, Image: Image, postdescription: postdescription, postdownloads: postdownloads,
      postlikes: postlikes, postOwnerId: postOwnerId, postOwnerImage: postOwnerImage, postOwnername: postOwnername, postType: postType,
    );

    Navigator.push(context, MaterialPageRoute(
        builder: (_) => SubComment(commentItem: commentItem)));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Ok"),
      onPressed:  () {
        FirebaseFirestore.instance.collection('comment')
            .doc(commentId).delete().then((value) {
          Fluttertoast.showToast(msg: 'Your comment has been deleted');
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text("AlertDialog"),
      content: const Text("Are you sure you want your comment to be permanently deleted ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    likerUserId = _auth.currentUser?.uid;
    likesCount = likes?.length ?? 0;

    notificationManager = NotificationManager();

    FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      token = snapshot.get('token');
    });

    FirebaseFirestore.instance.collection('users').doc(userId).get()
        .then<dynamic>((DocumentSnapshot snapshot) {
      tokens = snapshot.get('token');
    });

    var likeBadgeView = SSBadge(top: 0, right: 2,
        value: likesCount.toString(),
        child: IconButton(
            icon: const Icon(Icons.thumb_up_sharp, color: Colors.white,size:20 ,), onPressed: () {
          handleLikeComment();
        }));
    return
        Column(
      children: <Widget>[
        Container(
          color:Colors.grey.shade900,
    child:
        ListTile(
          selectedColor: Colors.grey,
          hoverColor: Colors.black,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Text(userName!, style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold,)),Text(comment!, style: TextStyle(color: Colors.white),),
    ],),     subtitle: Text(
          DateFormat("dd MMM, yyyy ").format(timestamp!).toString(),
          style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
        ),
          trailing: FirebaseAuth.instance.currentUser!.uid == userId
              ? Wrap(children:[
                likeBadgeView,
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white,),
                  color: Colors.white,
                  itemBuilder: (context)
              {
                return[
                  const PopupMenuItem<int>( value: 0, child: Text("Delete Comment"),),
                ];
              },
              onSelected: (value){
                if(value == 0){
                  showAlertDialog(context);
                }
              },)]):
          likeBadgeView,
          onTap: () {
            showSubcomments(context);
          },
          leading: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                  userId:userId,
                  userName:userName,
                  userImage: userImage,
                )));
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(userImage!),
              )
          ),
        ),
        ),
        const Divider(),
      ],
    );
  }
}
