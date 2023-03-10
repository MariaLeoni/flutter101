import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Usersx {
  Timestamp createdTime;
  String name;
  String id;
  String email;
  String userImage;

  Usersx({
    required this.createdTime,
     required this.name,
    required this.email ,
    required this.id,
    required this.userImage
  });

  factory Usersx.fromJson(Map<String, dynamic> json) {
    return Usersx(
        createdTime: json['createdAt'],
        name: json['name'],
        id: json['id'],
        email: json['email'],
        userImage: json['userImage']
    );
  }
}

//
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: <Widget>[
//       ListTile(contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
//         title: Text(name!),
//         //subtitle: Text(userId!),
//         leading: CircleAvatar(
//           backgroundImage: CachedNetworkImageProvider(userImage!),
//         ),
//       ),
//       const Divider(),
//     ]);
//   }
// }
