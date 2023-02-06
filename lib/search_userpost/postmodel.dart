import'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? image;
  String? name;
  String? userImage;
  Timestamp? createdAt;
  String? description;
  int? downloads;
  String? email;
  String? id;
  String? postId;

  PostModel({this.image, this.name, this.userImage, this.createdAt,
    this.description, this. downloads, this.email, this.id, this.postId,
  });

  PostModel.fromJson(Map<String, dynamic> json)
  {
    email = json['email'];
    name  = json['name'];
    userImage = json ['userImage'];
    createdAt = json ['createdAt'];
    id = json ['id'];
    image = json['Image'];
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
    data['Image'] = image;
    data['description']= description;
    data['downloads']= downloads;
    data['postId'] = postId;

    return data;
  }
}