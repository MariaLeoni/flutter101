import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../chat/chatWidgets.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../search_post/user.dart';
import '../search_post/users_specifics_page.dart';
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
  List<String> words = [];
  String str = '';
  int likesCount = 0;
  final firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  TextEditingController commentController = TextEditingController();
  String activityId = const Uuid().v4();
  List<String>? likes = List.empty(growable: true);
  List<String>? ids = List.empty(growable: true);
  NotificationManager? notificationManager;
  String? tokens;
  String? token;
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
        'Read Status': false,
        "PostType": widget.commentItem!.postType
      });
    }
    addCommentTaggingToActivityFeed2();
    commenterToken();
    commentController.clear();
  }
  addCommentTaggingToActivityFeed2() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.commentItem!.postOwnerId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.commentItem!.postOwnerId)
          .collection('FeedItems').doc(activityId).set({
        "type": "comment",
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
        'Read Status': false,
        "PostType": widget.commentItem!.postType
      });
    }
   postownerToken();
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
  void sendNotification(String action) {
    bool isNotPostOwner = token != tokens;
    if (isNotPostOwner) {
    NotificationModel model = NotificationModel(title: myName,
      body: action, dataBody: image,
      // dataTitle: "Should be post description"
    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }}
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
    if (commentController.text.startsWith('@')) {
      for (var item in ids!) {
        FirebaseFirestore.instance.collection('Activity Feed')
            .doc(item).collection('FeedItems').doc(activityId).
        set({
          "type": "tag",
          "name": myName,
          "userId": _auth.currentUser!.uid,
          "userProfileImage": myImage,
          "postId": widget.commentItem!.postId,
          "Activity Id": activityId,
          "Image":image,
          "timestamp": DateTime.now(),
          "commentData": commentController.text,
          "description": description,
          "downloads": downloads,
          "likes": likes,
          "postOwnerId": postOwnerId,
          "postOwnerImage": postOwnerImage,
          "postOwnername": postOwnername,
          "Read Status": false,
          "PostType":widget.commentItem!.postType,
        });
      }
      ids!.clear();
      gettagToken();
    }
     addCommentTaggingToActivityFeed();
    addCommentTaggingToActivityFeed2();
    sendNotification("commented on your post ");
    commentController.clear();
    commentId = const Uuid().v4();

  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(myUserId)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      id = snapshot.get('id');
      token = snapshot.get('token');
    });
  }
  void commenterToken() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.commentItem!.userId).get().then<dynamic>((DocumentSnapshot snapshot) {
      tokens = snapshot.get('token');
    });
    sendNotification("replied to your comment");
  }
  void postownerToken() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.commentItem!.postOwnerId).get().then<dynamic>((DocumentSnapshot snapshot) {
      tokens = snapshot.get('token');

    });
    sendNotification("Commented on your post");
  }
  void gettagToken() async {
    for (var item in ids!) {
      await FirebaseFirestore.instance.collection("users")
          .doc(item).get().then<dynamic>((DocumentSnapshot snapshot) {
        tokens = snapshot.get('token');
      });
      sendNotification("tagged you");
      ids!.clear();
    }}

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
    notificationManager = NotificationManager();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
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
      body: Container(
    decoration:  BoxDecoration(
    gradient: LinearGradient(
    colors:[Colors.grey.shade900, Colors.grey.shade900],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.2,0.9]
    ),
    ),
    child:
      Column(
        children: <Widget>[
          Column(children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
              title: Text(widget.commentItem!.comment!, style: TextStyle( color:Colors.white, fontWeight:FontWeight.bold,)),
              subtitle: Text(widget.commentItem!.userName!, style: TextStyle(color: Colors.white,)),
              leading: GestureDetector( onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                  userId:widget.commentItem!.userId,
                  userName:widget.commentItem!.userName!,
                  userImage: widget.commentItem!.userImage!,
                )));
              },
                child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.commentItem!.userImage!),
              ),
            )
            )
          ]
          ),
          const Divider(),
          Expanded(child: loadAndBuildComments()),
          const Divider(),
          ListTile(
              title:
              SizedBox(
                width: screen.width,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_8),
                  child:Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Sizes.dimen_30),
                      color: AppColors.greyColor,
                    ),child:Row(children: [
                      Container(
                        margin: const EdgeInsets.only(right: Sizes.dimen_4),
                        decoration: BoxDecoration(
                          color: AppColors.greyColor,
                          borderRadius: BorderRadius.circular(Sizes.dimen_20),
                        ),
                      ),
                      Flexible(child: TextField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: commentController,
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Type here...',
                            hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,)),
                        onChanged: (val) {
                          words = val.split(' ');
                          String taggedComment = words.isNotEmpty && words[words.length - 1].startsWith('@')
                              ? words[words.length - 1] : '';
                          if (taggedComment.length > 1){
                            setState(() {
                              str = taggedComment;
                            });
                          }
                        },
                        style: const TextStyle(backgroundColor: AppColors.greyColor,
                            color: Colors.black),
                      )),
                      Container(
                        margin: const EdgeInsets.only(left: Sizes.dimen_4),
                        decoration: BoxDecoration(
                          color: AppColors.greyColor,
                          borderRadius: BorderRadius.circular(Sizes.dimen_20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            commentController.text.isNotEmpty?
                            addComment(): Fluttertoast.showToast(msg: 'Your comment box is empty');
                          },
                          icon: const Icon(Icons.send_rounded),
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
    // TextFormField(
              //   controller: commentController,
              //   decoration: const InputDecoration(labelText: "Write a comment.."),
              // ),
              // trailing: OutlinedButton(
              //   onPressed: addComment,
              //   child: const Text("Post"),
              // )
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
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(model.userImage!),
                            ),
                            title: Text(model.name!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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
      ),)
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