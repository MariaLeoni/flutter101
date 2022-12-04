import'package:cloud_firestore/cloud_firestore.dart';

class Users
{
  String? email;
  String? name;
  String? userImage;
  Timestamp? createdAt;
  String? id;

  Users({
    this.email,
    this.name,
    this.userImage,
    this.createdAt,
    this.id,
});

  Users.fromJson(Map<String, dynamic> json)
  {
    email = json['email'];
     name  = json['name'];
     userImage = json ['userImage'];
     createdAt = json ['createdAt'];
     id = json ['id'];
  }
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['email'] = email;
    data['name'] = name;
    data['userImage'] = userImage;
    data['createdAt'] = createdAt;
    data['id'] = id;


    return data;
  }
}