
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/Learn/videoposts.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';



class Description2 extends StatefulWidget {

  String? videoFile;

  Description2({

    this.videoFile,


  });


  @override
  State<Description2> createState() => _Description2State();

}

class _Description2State extends State<Description2> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  FirebaseAuth _auth = FirebaseAuth.instance;
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;
  String? myImage;
  String? myName;

  addComment() {
    FirebaseFirestore.instance.collection('wallpaper2').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'video': widget.videoFile,
      'downloads': 0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'description': commentController.text,
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        VideoHomeScreen(
        )));
    if (!mounted) return;
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    widget.videoFile = null;
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
    _videoPlayerController1 = VideoPlayerController.network(widget.videoFile!);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      aspectRatio: 1,
      autoPlay: true,
      looping: false,
    );
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
          title: const Text(" View "),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
        child: Chewie( controller: _chewieController!,),),
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


