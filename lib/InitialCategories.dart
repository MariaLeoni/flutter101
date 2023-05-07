import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:uuid/uuid.dart';
import 'categoryView.dart';
import 'home_screen/home.dart';

import 'home_screen/picturesHomescreen.dart';
import 'misc/progressIndicator.dart';

class InitialCategories extends StatefulWidget {

  PostType? postType;
  InitialCategories({super.key, this.postType,});

  @override
  State<InitialCategories> createState() => InitialCategoriesState();
}

class InitialCategoriesState extends State<InitialCategories> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, List<String>?> interests = {};

  String? myImage;
  String? myName;
  File? videoFile;
  String? postUrl;
  File? imageFile;
  String title = "";




  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }



  @override
  void initState() {
    super.initState();
    readUserInfo();
    title = "Select your Campuses";
  }

  void updateInterests(Map<String, List<String>?> interests) {
    interests.forEach((key, value) {
      if (value == null || value.isEmpty) {
        interests.remove(key);
      }
    });
    setState(() {
      this.interests = interests;
    });
  }
addInterest() {
    FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid). update({'categories':interests});
}

skip(){
  Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen ()));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[SliverAppBar(
                flexibleSpace:Container(
                  color: Colors.red.shade900,
                ),
                title: Text(title,),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body:Container(color:Colors.black12,child: Column(
              children: <Widget>[
               Center(child: new Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                  updateInterests(interests);
                }, isEditable: false,)
                )),
                const SizedBox(height: 10.0,),
                OutlinedButton(
                 onPressed: addInterest,
                  child: const Text("Finish"),
                 ),
                OutlinedButton(
                  onPressed: skip,
                  child: const Text("skip"),
                ),
              ],
            )
        )
    ));
  }
}
