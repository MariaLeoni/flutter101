import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sharedstudent1/misc/global.dart';
import '../search_userpost/postmodel.dart';

class Post {
  String id = "";
  String source = "";
  String userImage = "";
  String userName = "";
  DateTime createdAt = DateTime.now();
  String email = "";
  int downloads = 0;
  String postId = "";
  String description ="";
  PostType? postType;
  
  List<String>? likes = List.empty(growable: true);
  List<String>? category = List.empty(growable: true);

  Post({
    required this.id,
    required this.source,
    required this.userImage,
    required this.createdAt,
    required this.userName,
    required this.email,
    required this.postId,
    required this.description,
    required this.downloads,
    required this.likes,
    required this.category,
  });

  static Post getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index, PostType type){
    String postSource = "";
    if (type == PostType.image){
      postSource = snapshot.data!.docs[index]['Image'];
    }
    else {
      postSource = snapshot.data!.docs[index]['video'];
    }

    return Post(id: snapshot.data?.docs[index]["id"],
        source: postSource,
        userImage: snapshot.data!.docs[index]['userImage'],
        createdAt: snapshot.data!.docs[index]['createdAt'].toDate(),
        userName: snapshot.data!.docs[index]['name'],
        email: snapshot.data!.docs[index]['email'],
        postId: snapshot.data!.docs[index]['postId'],
        downloads: snapshot.data!.docs[index]['downloads'],
        description: snapshot.data!.docs[index]['description'],
        likes: List.from(snapshot.data!.docs[index]['likes']),
        category: snapshot.data!.docs[index].toString().contains("category") ?
        List.from(snapshot.data!.docs[index]['category']) : List.empty()
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
        description: postModel.description!,
        likes: List.empty(),
        category: List.empty()
    );
  }
}