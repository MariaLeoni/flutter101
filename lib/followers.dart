import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../search_post/users_specific_posts.dart';


class Followers extends StatelessWidget {

  TextEditingController commentController1 = TextEditingController();

  final firebase = FirebaseFirestore.instance;

  String? userName;
  String? userImage;
  String? userId;
  String? followeruserId;
  String? comment;
  String? commentId;
  Timestamp? timestamp;
  List<String>? followers = List.empty(growable: true);
  String? originalCommentId;

  Followers({super.key,
    this.userName,
    this.userId,
    this.followeruserId,
    this.comment,
    this.timestamp,
    this.userImage,
    this.commentId,
    this.followers,
  });

  buildComments() {
    final firebaseCollection = FirebaseFirestore.instance.collection('users');


    return StreamBuilder(
      stream: firebaseCollection.where(
          FieldPath.documentId, whereIn:followers ).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        List<Followers> followers = [];
        for (var doc in snapshot.data!.docs) {
          followers.add(Followers.fromDocument(doc));
        }
        return ListView(
          children: followers,
        );
      },
    );
  }


  factory Followers.fromDocument(DocumentSnapshot doc){
    return Followers(
      userName: doc.data().toString().contains('name') ? doc.get(
          'name') : '',
      userId: doc.data().toString().contains('id') ? doc.get(
          'id') : '',
      userImage: doc.data().toString().contains('userImage') ? doc.get(
          'userImage') : '',
      followers: doc.data().toString().contains('followers') ? List
          .from(doc.get('followers')) : List.empty(),
    );
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
          title: const Text("Followers"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            const Divider(),
            // ListTile(
            //   contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
            //   title: Text(userName!),
            //   leading: CircleAvatar(
            //     backgroundImage: CachedNetworkImageProvider(userImage!),
            //   ),
            // )
          ],
        )
    );
  }
}