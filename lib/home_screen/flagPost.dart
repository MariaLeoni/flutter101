import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import '../widgets/input_field.dart';

class FlagAPost extends StatefulWidget {

  Post? post;

  FlagAPost({super.key, required this.post,});

  @override
  State<FlagAPost> createState() => FlagAPostState();
}

class FlagAPostState extends State<FlagAPost> {
  TextEditingController commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? myName;
  String? myEmail;

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).get().then<dynamic>((DocumentSnapshot snapshot) {
      myEmail = snapshot.get('email');
      myName = snapshot.get('name');
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
      readUserInfo();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[SliverAppBar(
                flexibleSpace:Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.2],
                    ),
                  ),
                ),
                title: const Text("Flag a Post"),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body: Container(color: Colors.black,
              child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0,),
                Text("Hello $myName"),
                const SizedBox(height: 10.0,),
                SizedBox.fromSize(size: const Size(350.0,  200),
                    child: InputField(
                      textEditingController: commentController, hintText: "What do you want to report...", icon: Icons.send,
                       obscureText: false,
                    )
                ),
                const SizedBox(height: 10.0,),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade900),
                      minimumSize: MaterialStateProperty.all(const Size(150, 50))
                  ),
                  onPressed: reportPost,
                  child: const Text('Report'),
                ),
                const SizedBox(height: 30.0,),
              ],
            ),)
        )
    );
  }

  void reportPost(){
    if (commentController.text.isEmpty){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter the reason why you want to flag this post")));
    }
    else{
      FirebaseFirestore.instance.collection('FlaggedPosts').add({
        'reporterId': _auth.currentUser!.uid,
        'postId': widget.post?.postId,
        'postType': widget.post?.postType,
        'reporterName': myName,
        'email': myEmail,
        'reportedOn': DateTime.now(),
        'report': commentController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Thanks, Post successfully flagged. Our Moderators will look into it")));
      Navigator.pop(context);
    }
  }
}
