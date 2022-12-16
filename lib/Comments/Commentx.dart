import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:sharedstudent1/owner_details/owner_details.dart';
import 'package:flutter/widgets.dart';
final commentsRef = FirebaseFirestore.instance.collection('comment');

class Comment extends StatefulWidget {
  String? docId;
  String? postImage;
  String? postcreatedAt;

Comment({
  this.docId,
  this.postImage,
  this.postcreatedAt,
});

  @override
  State<Comment> createState() => CommentState(
    postid: this.docId,
    postImage: this.postImage,
    postcreatedAt: this.postcreatedAt,
  );
}

class CommentState extends State<Comment> {
  TextEditingController commentController = TextEditingController();


  String? postid;
  String? postImage;
  String? postcreatedAt;
  String? myImage;
  String? myName;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  CommentState({
    this.postid,
    this.postImage,
    this.postcreatedAt,
  });

  void read_userInfo()async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot)
    {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read_userInfo();
    Fluttertoast.showToast(msg: 'Inside Comments screen');
  }


  buildComments() {
    FirebaseFirestore.instance.collection('comment').doc(widget.docId).collection('comments')
        .orderBy("timestamp", descending: false).snapshots();
        builder: (context,snapshot)
         {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments =[];

          snapshot.data?.docs.forEach((doc) {
           MyComments myComment = MyComments(
             username: doc['username'],
             userId: doc['userId'],
             comment: doc['comment'],
             timestamp: doc['timestamp'],
             avatarUrl: doc['avatarUrl'],
           );
           //comments.add(null);
         });
         return ListView(
           children: comments,
         );
         };
  }

  addComment() {
    FirebaseFirestore.instance.collection('comment').doc(widget.docId).collection('comments').add({
      "comment": commentController.text,
      "userImage": myImage,
      "userName" : myName,
      "timestamp": DateTime.now(),
    });

    commentController.clear();
  }

  Widget listViewWidget (String docId, String img, String userImg, String name, DateTime date, String userId, int downloads, )
  {
    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            userImg,
                          ),
                        ),
                        const SizedBox(width: 10.0,),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
                                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                              )
                            ]
                        )
                      ]
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: "Comments"),
        body:Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            const Divider(),
            ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: "Write a comment.."),
                ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  child: Text("Post"),

                )
            ),
          ],
        ));
      }
    }

  circularProgress() {}


  header(BuildContext context, {required String titleText}) {}

  class MyComments extends StatelessWidget{
    final String username;
    final String userId;
    final String avatarUrl;
    final String comment;
    final Timestamp timestamp;

    MyComments({
      required this.username,
       required this.userId,
      required this.avatarUrl,
      required this.comment,
      required this.timestamp,
  });

    factory MyComments.fromDocument(DocumentSnapshot doc){
      return MyComments(
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


