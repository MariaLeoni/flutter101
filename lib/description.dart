

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'home_screen/homescreen.dart';

class Description extends StatefulWidget {

  String? imageFile;

  Description({

    this.imageFile,


  });


  @override
  State<Description> createState() => _DescriptionState();

}

class _DescriptionState extends State<Description> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  FirebaseAuth _auth = FirebaseAuth.instance;

  String? myImage;
  String? myName;

  addComment() {
    FirebaseFirestore.instance.collection('wallpaper').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'Image': widget.imageFile,
      'downloads': 0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'followers':<String>[],
      'description': commentController.text,
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        HomeScreen(
        )));
    if (!mounted) return;
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    widget.imageFile = null;
  }
  void readUserInfo() async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot)
    {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }
  @override
  void initState() {
    super.initState();
    readUserInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2],
              ),
            ),
          ),
          title: const Text("Comments"),
        ),
        body: Column(
          children: <Widget>[
            Image.network(
              widget.imageFile!,
              width: MediaQuery.of(context).size.width,
            ),
        //    Expanded(child: buildComments()),
            const Divider(),
            ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: "Write a comment.."),
                ),
                trailing: OutlinedButton(
                 onPressed: addComment,
                  child: const Text("Post"),
                )
            ),
          ],
        )
    );
  }

}

