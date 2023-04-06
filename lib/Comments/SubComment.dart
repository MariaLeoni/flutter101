import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String? image;
  int likesCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  TextEditingController commentController = TextEditingController();
  String activityId = const Uuid().v4();
  List<String>? likes = List.empty(growable: true);

  addCommentTaggingToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.commentItem!.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.commentItem!.userId)
          .collection('FeedItems').doc(activityId).set({
        "type": "commentReply",
        "name": myName,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": myImage,
        "postId": widget.commentItem!.postId,
        "Activity Id": activityId,
        "Image": image,
        "timestamp": DateTime.now(),
        "commentData":  commentController.text,
        "description": description,
        "downloads": downloads,
        "likes": likes,
        "postOwnerId": postOwnerId,
        "postOwnerImage": postOwnerImage,
        "postOwnername": postOwnername,
        'Read Status': false
      });
    }
    commentController.clear();
  }

  loadAndBuildComments(){
    if (widget.commentItem!.subCommentsIds != null && widget.commentItem!.subCommentsIds!.isEmpty){
      return const Text('There are no comments for this comment');
    }
    else{
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
            CommentItem commentItem = CommentItem.fromDocument(doc);
            comments.add(commentItem);
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
  }
  // AddLike(){
  //
  //   bool isNotPostOwner = _auth.currentUser!.uid != widget.commentItem!.userId;
  //   if (isNotPostOwner) {
  //     FirebaseFirestore.instance.collection('Activity Feed').doc(widget.commentItem!.userId)
  //         .collection('FeedItems').doc(activityId)
  //         .set({
  //       "type": "like Comment",
  //       "name": myName,
  //       "userId": _auth.currentUser!.uid,
  //       "userProfileImage": myImage,
  //       "postId": widget.commentItem!.postId,
  //       "Activity Id": activityId,
  //       "Image": image,
  //       "timestamp": DateTime.now(),
  //       "commentData": null,
  //       "downloads": downloads,
  //       "description": description,
  //       "likes": likes,
  //       "postOwnerId": postOwnerId,
  //       "postOwnerImage": postOwnerImage,
  //       "postOwnername": postOwnername,
  //       "Read Status": false,
  //
  //     });
  //   }
  //
  // }
  // handleLikeComment() {
  //   if (widget.commentItem!.likes!= null && widget.commentItem!.likes!.contains(_auth.currentUser!.uid)) {
  //     Fluttertoast.showToast(msg: "You unliked this comment!");
  //     widget.commentItem!.likes!.remove(_auth.currentUser!.uid);
  //   }
  //   else {
  //     Fluttertoast.showToast(msg: "You liked this comment!");
  //     widget.commentItem!.likes!.add(_auth.currentUser!.uid);
  //   }
  //
  //   FirebaseFirestore.instance.collection('comment').doc(commentId)
  //       .update({'likes':widget.commentItem!.likes!,
  //   }).then((value) {
  //     likesCount = (widget.commentItem!.likes?.length ?? 0);
  //   });
  //     AddLike();
  // }
  addComment() {
    widget.commentItem!.subCommentsIds?.add(commentId);
    setState(() {
      widget.commentItem!.subCommentsIds;
    });

    print("CommentId $commentId and postId $postId");
    firestore.collection('comment').doc(commentId).set({
      "comment": commentController.text,
      "commenterImage": myImage,
      "commenterName" : myName,
      "timestamp": DateTime.now(),
      "commenterId": id,
      "originalCommentId": widget.commentItem?.commentId,
      "originalCommenterId": widget.commentItem?.userId,
      "commentId": commentId,
      'subCommentIds': <String>[],
      'likes': <String>[],
      "postId": postId!,
      "Image" : widget.commentItem!.Image,
      "description": widget.commentItem!.postdescription,
      "downloads": widget.commentItem!.postdownloads,
      "postlikes": widget.commentItem!.postlikes,
      "postOwnername": widget.commentItem!.postOwnername,
      "postOwnerImage": widget.commentItem!.postOwnerImage,
      "postOwnerId": widget.commentItem!.postOwnerId,
    });

    firestore.collection('comment').doc(widget.commentItem?.commentId)
        .update({'subCommentIds': FieldValue.arrayUnion(List<String>.filled(1, commentId)),
    });

     addCommentTaggingToActivityFeed();
    commentController.clear();
    commentId = const Uuid().v4();

  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(myUserId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      id = snapshot.get('id');
    });
  }

  void loadPostInfo() async {
    FirebaseFirestore.instance.collection('wallpaper').doc(widget.commentItem!.postId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      description = snapshot.get('description');
      likes = List.from(snapshot.get('likes'));
      downloads = snapshot.get('downloads');
      postOwnerId = snapshot.get('id');
      postOwnername = snapshot.get('name');
      postOwnerImage = snapshot.get('userImage');
      image = snapshot.get('Image');
    });
  }

  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    postId = widget.commentItem!.postId;

    readUserInfo();
    loadPostInfo();
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
          Expanded(child: loadAndBuildComments()),
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