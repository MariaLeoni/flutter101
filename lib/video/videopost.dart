import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  String id = "";
  String postId = "";
  String video = "";
  String userImage = "";
  String name = "";
  DateTime createdAt = DateTime.now();
  String email = "";
  int downloads = 0;
  String description = "";
  List<String>? likes = List.empty(growable: true);


  Post({
    required this.id,
    required this.video,
    required this.userImage,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.downloads,
    required this.description,
    required this.postId,
    required this.likes,
  });

  static Post getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index) {
    return Post(id: snapshot.data?.docs[index]["id"],
        video: snapshot.data!.docs[index]['video'],
        userImage: snapshot.data!.docs[index]['userImage'],
        createdAt: snapshot.data!.docs[index]['createdAt'].toDate(),
        name: snapshot.data!.docs[index]['name'],
        email: snapshot.data!.docs[index]['email'],
        downloads: snapshot.data!.docs[index]['downloads'],
       description: snapshot.data!.docs[index]['description'],
      postId: snapshot.data!.docs[index]['postId'],
      likes: List.from(snapshot.data!.docs[index]['likes']),
    );
  }
}