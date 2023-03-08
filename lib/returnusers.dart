import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersModel extends StatelessWidget {

  String? name;
  String? userImage;
  String? userId;
  String? email;


  UsersModel({super.key,
    this.name,
    this.userId,
    this.email,
    this.userImage
  });


  factory UsersModel.fromDocument(DocumentSnapshot doc){
    return UsersModel(
      name: doc.data().toString().contains('name') ? doc.get('name') : '',
      userId: doc.data().toString().contains('id') ? doc.get('id') : '',
      userImage: doc.data().toString().contains('userImage') ? doc.get(
          'userImage') : '',
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
        title: Text(name!),
        //subtitle: Text(userId!),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userImage!),
        ),
      ),
      const Divider(),
    ]);
  }
}
