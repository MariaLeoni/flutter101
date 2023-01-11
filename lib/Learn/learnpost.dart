import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  String id = "";
  String video = "";
  String userImage = "";
  String userName = "";
  DateTime createdAt = DateTime.now();
  String email = "";
  int downloads = 0;


  Post({
    required this.id,
    required this.video,
    required this.userImage,
    required this.createdAt,
    required this.userName,
    required this.email,
    required this.downloads,

  });

  static Post getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index) {
    return Post(id: snapshot.data?.docs[index]["id"],
        video: snapshot.data!.docs[index]['Video'],
        userImage: snapshot.data!.docs[index]['userImage'],
        createdAt: snapshot.data!.docs[index]['createdAt'].toDate(),
        userName: snapshot.data!.docs[index]['name'],
        email: snapshot.data!.docs[index]['email'],
        downloads: snapshot.data!.docs[index]['downloads'],

    );
  }
}