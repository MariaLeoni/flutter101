import'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharedstudent1/misc/global.dart';

class PostModel {
  String? source;
  String? name;
  String? userImage;
  Timestamp? createdAt;
  String? description;
  int? downloads;
  String? email;
  String? id;
  String? postId;
  PostType? type;

  PostModel({this.source, this.name, this.userImage, this.createdAt,
    this.description, this. downloads, this.email, this.id, this.postId, this.type,
  });

  PostModel.fromJson(Map<String, dynamic> json, PostType type){
    email = json['email'];
    name  = json['name'];
    userImage = json ['userImage'];
    createdAt = json ['createdAt'];
    id = json ['id'];

    if (type == PostType.image) {
      source = json['Image'];
    } else {
      source = json['video'];
    }

    description = json['description'];
    downloads = json['downloads'];
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['userImage'] = userImage;
    data['createdAt'] = createdAt;
    data['id'] = id;
    if (type == PostType.image) {
      data['Image'] = source;
    } else {
      data['video'] = source;
    }
    data['Image'] = source;
    data['description']= description;
    data['downloads']= downloads;
    data['postId'] = postId;
    return data;
  }
}