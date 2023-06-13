import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:uuid/uuid.dart';
import 'categoryView.dart';
import 'home_screen/home.dart';
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
  Finish() async {
    if (interests.isNotEmpty){
      await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'interests': interests,
      });
      skip();
    }
    return true;

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

skip(){
  Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[SliverAppBar(
                flexibleSpace:Container(
                  color: Colors.black,
                ),
                title: Text(title,),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body:Container(color:Colors.black,child: Column(
              children: <Widget>[
                Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                  updateInterests(interests);
                }, isEditable: true,)
                ),
               // const SizedBox(height: 10.0,),
(
                Container(color:Colors.red.shade900,child:OutlinedButton(
                 onPressed:  Finish,
                  child: const Text("Finish", style:TextStyle(color:Colors.white,)),
                   ))),
                SizedBox(height:10.0),
                Container(color:Colors.red.shade900,child:OutlinedButton(
                  onPressed: skip,
                  child: const Text("skip", style:TextStyle(color:Colors.white)),
                )),
              ],
            )
        )
    ));
  }
}
