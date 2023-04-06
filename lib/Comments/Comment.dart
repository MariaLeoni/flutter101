import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:sharedstudent1/Comments/CommentItem.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../search_post/user.dart';

class Comment extends StatefulWidget {

  String? userId;
  String? postId;
  String? docId;
  String? image;
  String? postOwnerImg;
  String? postOwnername;
  List<String>? likes = List.empty(growable: true);
  String? description;
  int? downloads;

  Comment({super.key, this.userId, this.postId, this.docId, this.image, 
    this.likes, this.description,this.downloads, this.postOwnerImg, this.postOwnername, });

  @override
  State<Comment> createState() => CommentState();
}

class CommentState extends State<Comment> {
  String? userId;
  String? commenterId;
  String? myImage;
  String? myName;
  String? id;
  String? token;
  String commentId = const Uuid().v4();
  String activityId = const Uuid().v4();
  String? myUserId;
  List<String> words = [];
  String str = '';
  NotificationManager? notificationManager;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  TextEditingController commentController = TextEditingController();
  List<String>? ids = List.empty(growable: true);
  List<String>? likes = List.empty(growable: true);
  int likesCount = 0;
  loadAndBuildComments(){
    final firebaseCollection = FirebaseFirestore.instance.collection('comment');

    return StreamBuilder(
      stream: firebaseCollection.where("postId", isEqualTo: widget.postId)
      .where("originalCommentId", isNull: true)
          .snapshots(),
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        List<CommentItem> commentViews = [];

        for (var doc in snapshot.data!.docs) {
          CommentItem commentItem = CommentItem.fromDocument(doc);
          commentViews.add(commentItem);
        }

        commentViews.sort((a,b) {
          var aTimeStamp = a.timestamp;
          var bTimeStamp = b.timestamp;
          return aTimeStamp!.compareTo(bTimeStamp!);
        });
        return ListView(children: commentViews);
      },
    );
  }

  void getOPToken() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.userId).get().then<dynamic>((DocumentSnapshot snapshot) {
      token = snapshot.get('devicetoken');
      print("Token $token");
    });
  }

  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: myName,
      body: action, dataBody: widget.image,
      //dataTitle: "Should be post description"
        );
    if (token != null) {
      notificationManager?.sendNotification(token!, model);
    }
  }

  // handleLikeComment() {
  //   if (likes!= null && likes!.contains(_auth.currentUser!.uid)) {
  //     Fluttertoast.showToast(msg: "You unliked this comment!");
  //     likes!.remove(_auth.currentUser!.uid);
  //   }
  //   else {
  //     Fluttertoast.showToast(msg: "You liked this comment!");
  //     likes!.add(_auth.currentUser!.uid);
  //   }
  //
  //   FirebaseFirestore.instance.collection('comment').doc(commentId)
  //       .update({'likes': likes!,
  //   }).then((value) {
  //     likesCount = (likes?.length ?? 0);
  //   });
  //   AddLike();
  // }
  //
  // AddLike(){
  //   bool isNotPostOwner = _auth.currentUser!.uid != commenterId;
  //   if (isNotPostOwner) {
  //     FirebaseFirestore.instance.collection('Activity Feed').doc(commenterId)
  //         .collection('FeedItems').doc(activityId)
  //         .set({
  //       "type": "like Comment main",
  //       "name": myName,
  //       "userId": _auth.currentUser!.uid,
  //       "userProfileImage": myImage,
  //       "postId": widget.postId,
  //       "Activity Id": activityId,
  //       "Image": widget.image,
  //       "timestamp": DateTime.now(),
  //       "commentData": null,
  //       "downloads": widget.downloads,
  //       "description": widget.description,
  //       "likes": widget.likes,
  //       "postOwnerId": widget.userId,
  //       "postOwnerImage": widget.postOwnerImg,
  //       "postOwnername": widget.postOwnername,
  //       "Read Status": false,
  //
  //     });
  //   }
  //
  // }
  addCommentTaggingToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.userId)
          .collection('FeedItems').doc(activityId).set({
        "type": "comment",
        "name": myName,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": myImage,
        "postId": widget.postId,
        "Activity Id": activityId,
        "Image": widget.image,
        "timestamp": DateTime.now(),
        "commentData":  commentController.text,
        "description": widget.description,
         "downloads": widget.downloads,
         "likes": widget.likes,
        "postOwnerId": widget.userId,
        "postOwnerImage": widget.postOwnerImg,
         "postOwnername": widget.postOwnername,
        'Read Status': false
          });
    }
    ids!.clear();
    commentController.clear();
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
      'Image': widget.image,
      "description": widget.description,
      "downloads": widget.downloads,
      "postlikes": widget.likes,
      "postOwnerId": widget.userId,
      "postOwnerImage": widget.postOwnerImg,
      "postOwnername": widget.postOwnername,
    });

    if (commentController.text.startsWith('@')) {
      for (var item in ids!) {
        FirebaseFirestore.instance.collection('Activity Feed')
            .doc(item).collection('FeedItems').doc(activityId).
        set({
          "type": "tag",
          "name": myName,
          "userId": _auth.currentUser!.uid,
          "userProfileImage": myImage,
          "postId": widget.postId,
          "Activity Id": activityId,
          "Image": widget.image,
          "timestamp": DateTime.now(),
          "commentData": commentController.text,
          "description": widget.description,
          "downloads": widget.downloads,
          "likes": widget.likes,
          "postOwnerId": widget.userId,
          "postOwnerImage": widget.postOwnerImg,
          "postOwnername": widget.postOwnername,
          "likes": widget.likes,
          "downloads": widget.downloads,
          "Read Status": false,
          "Activity Id": activityId
        });
      }
      ids!.clear();
    }

    addCommentTaggingToActivityFeed();

    sendNotification("Commented on your post");
    commentController.clear();
    commentId = const Uuid().v4();
    FocusScope.of(context).unfocus();
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(myUserId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      id = snapshot.get('id');
    });
  }
  void commentLikes() async {
    FirebaseFirestore.instance.collection('comment').doc(commentId).get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      likes = List.from(snapshot.get('likes'));
      commenterId = snapshot.get('commenterId');

    });
  }
  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    readUserInfo();
    getOPToken();
    commentLikes();
    notificationManager = NotificationManager();
    notificationManager?.initServer();
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
            Expanded(child: loadAndBuildComments()),
            const Divider(),
            ListTile(title: TextFormField(
                controller: commentController,
                decoration: const InputDecoration(labelText: "Write a comment.."),
                onChanged: (val) {
                  words = val.split(' ');
                  String taggedComment = words.isNotEmpty && words[words.length - 1].startsWith('@')
                      ? words[words.length - 1] : '';
                  if (taggedComment.length > 1){
                    setState(() {
                      str = taggedComment;
                    });
                  }
                }
            ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  child: const Text("Post"),
                )
            ),
            str.length > 1 ?
            StreamBuilder<QuerySnapshot>(
                stream: searchForUser("users", 100, str.split("@")[1]),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if ((snapshot.data?.docs.length ?? 0) > 0) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Users model = Users.fromJson(snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                          return ListTile(
                              title: Text(model.name!, style: const TextStyle(color: Colors.black),),
                              onTap: () {
                                String tmp = str.substring(1, str.length);
                                setState(() {
                                  str = '';
                                  commentController.text += model.name!.
                                  substring(
                                      model.name!.indexOf(tmp) + tmp.length, model.name!.length)
                                      .replaceAll(' ', '_');
                                  ids?.add(model.id!);
                                });

                                //Move cursor to end of text
                                String inputSoFar = commentController.text;
                                commentController.value = TextEditingValue(
                                  text: inputSoFar,
                                  selection: TextSelection.collapsed(offset: inputSoFar.length),
                                );
                              });
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                      );
                    }
                  }
                  return const SizedBox();
                }) : const SizedBox(),
            const SizedBox(height: 25),
          ],
        )
    );
  }

  Stream<QuerySnapshot> searchForUser(String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore.collection(collectionPath).limit(limit)
          .where("name", isGreaterThanOrEqualTo: textSearch)
          .where("name", isLessThanOrEqualTo: '$textSearch\uf8ff')
          .snapshots();
    } else {
      return firebaseFirestore.collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }
}