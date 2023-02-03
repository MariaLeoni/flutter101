import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedstudent1/video/videoposts.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import 'misc/progressIndicator.dart';

class VideoUploader extends StatefulWidget {

  String? imageFrom;
  VideoUploader({super.key, this.imageFrom,});

  @override
  State<VideoUploader> createState() => VideoUploaderState();
}

class VideoUploaderState extends State<VideoUploader> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? myImage;
  String? myName;
  File? videoFile;
  String? videoUrl;

  late VideoPlayerController videoPlayerController1;
  late ChewieController chewieController;


  addComment() {
    FirebaseFirestore.instance.collection('wallpaper2').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'video': videoFile,
      'downloads': 0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'description': commentController.text,
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VideoHomeScreen()));
    if (!mounted) return;
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }

  void showAlert(){
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: const Text("Please choose an option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                getFromCamera();
              },
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(4.0,),
                    child: Icon(Icons.camera, color: Colors.red,),
                  ),
                  Text("Camera", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                getFromGallery();
              },
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(4.0,),
                    child: Icon(Icons.image, color: Colors.redAccent,),
                  ),
                  Text("Gallery", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      context: context,
    );
  }

  @override
  void initState() {
    super.initState();

    readUserInfo();

    Timer.run(() {
      showAlert();
    });
  }

  void getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        videoFile = File(pickedFile.path);
      });

      uploadVideo();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        videoFile = File(pickedFile.path);
      });

      uploadVideo();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void uploadVideo() async {
    if(videoFile == null) {
      Fluttertoast.showToast(msg: 'Please select a Video');
      return;
    }
    try {
      LoadingIndicatorDialog().show(context);

      final ref = FirebaseStorage.instance.ref().child('userVideos').child('${DateTime.now()}mp4');
      await ref.putFile(videoFile!);
      String path = await ref.getDownloadURL();
      setState(() {
        videoUrl = path;
      });

      LoadingIndicatorDialog().dismiss();
      videoPlayerController1 = VideoPlayerController.network(videoUrl!!);
      chewieController = ChewieController(videoPlayerController: videoPlayerController1,
                          aspectRatio:5/8, autoPlay: true, looping: false,);
    }
    catch(error) {
      Fluttertoast.showToast(msg: error.toString());
    }
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
          title: const Text("Post"),
        ),
        body: SingleChildScrollView(
            child: ConstrainedBox(constraints: const BoxConstraints(),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap:() {
                        showAlert();
                      },
                      child: videoUrl == null ? Image.asset("assets/images/wolf.webp") :
                              Chewie(controller: chewieController!)),
                    const SizedBox(height: 10.0,),
                    SizedBox.fromSize(
                        size: const Size(300, 50), // Image radius
                        child: TextFormField(
                          controller: commentController,
                          decoration: const InputDecoration(labelText: "Add a description..."),
                        )
                    ),
                    const SizedBox(height: 10.0,),
                    OutlinedButton(
                      onPressed: addComment,
                      child: const Text("Post"),
                    ),
                  ],
                )
            )
        )
    );
  }
}
