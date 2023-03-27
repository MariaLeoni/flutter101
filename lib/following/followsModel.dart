import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowerModel extends StatelessWidget {

  String? userName;
  String? userImage;
  String? userId;
  List<String>? followers = List.empty(growable: true);

  FollowerModel({super.key,
    this.userName,
    this.userId,
    this.followers,
    this.userImage
  });


  factory FollowerModel.fromDocument(DocumentSnapshot doc){
    return FollowerModel(
      userName: doc.data().toString().contains('name') ? doc.get('name') : '',
      userId: doc.data().toString().contains('id') ? doc.get('id') : '',
      userImage: doc.data().toString().contains('userImage') ? doc.get('userImage') : '',
      followers: doc.data().toString().contains('followers') ? List.from(doc.get('followers')) : List.empty(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(contentPadding: const EdgeInsets.only(left: 2.0, right: 0.0),
        title: Text(userName!),
        //subtitle: Text(userId!),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userImage!),
        ),
      ),
      const Divider(),
    ]);
  }
}