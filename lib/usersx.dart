import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sharedstudent1/misc/global.dart';
import '../search_userpost/postmodel.dart';

class Usersx {
  String id = "";
  String name= "";
  String userImage = "";
  String email = "";


  Usersx({
    required this.id,
    required this.userImage,
    required this.name,
    required this.email,

  });

  static Usersx getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index, ){

    return Usersx(id: snapshot.data?.docs[index]["id"],
        userImage: snapshot.data!.docs[index]['userImage'],
        name: snapshot.data!.docs[index]['name'],
        email: snapshot.data!.docs[index]['email'],
    );
  }

  static Post getPostSnapshot(Map<String, dynamic> data, PostType type){
    PostModel postModel = PostModel.fromJson(data, type);

    return Post(id: postModel.id!,
        source: postModel.source!,
        userImage: postModel.userImage!,
        createdAt:postModel.createdAt!.toDate(),
        userName: postModel.name!,
        email: postModel.email!,
        postId: postModel.postId!,
        downloads: postModel.downloads!,
        viewCount: postModel.viewcount!,
        description: postModel.description!,
        likes: List.empty(),
        category: List.empty()
    );
  }
