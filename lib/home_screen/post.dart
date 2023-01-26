import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Post {
  String id = "";
  String image = "";
  String userImage = "";
  String userName = "";
  DateTime createdAt = DateTime.now();
  String email = "";
  int downloads = 0;
  String postId = "";
  String description ="";
  List<String>? likes = List.empty(growable: true);

  Post({
    required this.id,
    required this.image,
    required this.userImage,
    required this.createdAt,
    required this.userName,
    required this.email,
    required this.postId,
    required this.description,
    required this.downloads,
    required this.likes
  });

  static Post getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index){

    return Post(id: snapshot.data?.docs[index]["id"],
        image: snapshot.data!.docs[index]['Image'],
        userImage: snapshot.data!.docs[index]['userImage'] ,
        createdAt:snapshot.data!.docs[index]['createdAt'].toDate(),
        userName: snapshot.data!.docs[index]['name'],
        email:  snapshot.data!.docs[index]['email'],
        postId:snapshot.data!.docs[index]['postId'],
        downloads:snapshot.data!.docs[index]['downloads'],
        description:snapshot.data!.docs[index]['description'],
        likes: List.from(snapshot.data!.docs[index]['likes'])
    );
  }
}