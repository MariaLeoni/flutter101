import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import 'package:uuid/uuid.dart';
import 'categoryView.dart';
import 'home_screen/home.dart';
import 'misc/progressIndicator.dart';

class PostUploader extends StatefulWidget {

  PostType? postType;
  PostUploader({super.key, this.postType,});

  @override
  State<PostUploader> createState() => PostUploaderState();
}

class PostUploaderState extends State<PostUploader> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, List<String>?> interests = {};
  List<String> selectedInterests = List.empty(growable: true);

  String? myImage;
  String? myName;
  File? videoFile;
  String? postUrl;
  File? imageFile;
  String title = "";


  postVideo() {
    FirebaseFirestore.instance.collection('wallpaper2').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'video': postUrl,
      'downloads': 0,
      'viewcount':0,
      'viewers': <String>[],
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'description': commentController.text,
      'category': selectedInterests,
    });

    LoadingIndicatorDialog().dismiss();

    if (!mounted) return;
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  postPicture() {
    FirebaseFirestore.instance.collection('wallpaper').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'Image': postUrl,
      'downloads': 0,
      'viewcount':0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'viewers':<String>[],
      'description': commentController.text,
      'category': selectedInterests,
    });

    LoadingIndicatorDialog().dismiss();

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
                cameraSource();
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
                gallerySource();
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

    title = widget.postType == PostType.video ? "Post A Video" : "Post A Picture";

    Timer.run(() {
      showAlert();
    });
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

  void getImageFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);
    cropImage(pickedFile!.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void getImageFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    cropImage(pickedFile!.path);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void cameraSource(){
    if (widget.postType == PostType.video){
      getVideoFromCamera();
    }
    else {
      getImageFromCamera();
    }
  }

  void gallerySource(){
    if (widget.postType == PostType.video){
      getVideoFromGallery();
    }
    else {
      getImageFromGallery();
    }
  }

  void cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage
      (sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void getVideoFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        videoFile = File(pickedFile.path);
        setVideo();
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void getVideoFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        videoFile = File(pickedFile.path);
        setVideo();
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void setVideo(){
    if(videoFile == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Looks like no video was selected or captured")));
        return;
    }
  }

  void uploadPost() async {

    interests.forEach((key, value) {
      if (value != null) {
        selectedInterests.addAll(value);
      }
    });

    if(videoFile == null && imageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Looks like no media was selected or captured")));
      return;
    }
    try {
      LoadingIndicatorDialog().show(context);

      if (widget.postType == PostType.video){
        final ref = FirebaseStorage.instance.ref().child('userVideos').child('${DateTime.now()}mp4');
        await ref.putFile(videoFile!);
        String path = await ref.getDownloadURL();
        setState(() {
          postUrl = path;
          postVideo();
        });
      }
      else if (widget.postType == PostType.image){
        final ref = FirebaseStorage.instance.ref().child('userImages')
            .child('${DateTime.now()}jpg');
        await ref.putFile(imageFile!);
        String path = await ref.getDownloadURL();
        setState(() {
          postUrl = path;
          postPicture();
        });
      }
      else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Sorry, unknown post type")));
      }
    }
    catch(error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[SliverAppBar(title: Text(title,),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body: Column(
              children: <Widget>[
                GestureDetector(
                  onTap:() {
                    showAlert();
                  },
                  child: widget.postType == PostType.video ? (videoFile == null ? Image.asset("assets/images/wolf.webp") :
                  Flexible(child: AspectRatio(aspectRatio: 16/9,
                    child: BetterPlayer.file(videoFile!.path,
                      betterPlayerConfiguration: const BetterPlayerConfiguration(
                        aspectRatio: 16 / 9,
                      ),
                    ),
                  ))) : (imageFile == null ? Image.asset("assets/images/wolf.webp") :
                  Image.file(imageFile!))),
                Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                  updateInterests(interests);
                }, isEditable: false,)
                ),
                Flexible(child: TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(labelText: "Add a title..."),
                    )
                ),
                const SizedBox(height: 10.0,),
                OutlinedButton(
                  onPressed: uploadPost,
                  child: const Text("Post"),
                )
              ],
            )
        )
    );
  }
}
