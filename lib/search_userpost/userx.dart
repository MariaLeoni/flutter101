import'package:cloud_firestore/cloud_firestore.dart';

class Posts
{
  String? Image;
  String? name;
  String? userImage;
  Timestamp? createdAt;
  String? description;
  int? downloads;
  String? email;
  String? id;
  String? postId;

  Posts({
    this.Image,
    this.name,
    this.userImage,
    this.createdAt,
    this.description,
    this. downloads,
    this.email,
    this.id,
    this.postId,

  });

  Posts.fromJson(Map<String, dynamic> json)
  {
    email = json['email'];
     name  = json['name'];
     userImage = json ['userImage'];
     createdAt = json ['createdAt'];
     id = json ['id'];
     Image = json['Image'];
      description = json['description'];
      downloads = json['downloads'];
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['email'] = email;
    data['name'] = name;
    data['userImage'] = userImage;
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['Image']= Image;
    data['description']= description;
    data['downloads']= downloads;
    data['postId'] = postId;

    return data;
  }
}