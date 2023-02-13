import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'categoryView.dart';
import 'home_screen/picturesHomescreen.dart';

class Uploader extends StatefulWidget {

  Uploader({super.key,});

  @override
  State<Uploader> createState() => UploaderState();
}

class UploaderState extends State<Uploader> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, List<String>?> interests = {};

  String? myImage;
  String? myName;
  File? imageFile;
  String? imageUrl;

  void updateInterests(Map<String, List<String>?> interests) {
    setState(() {
      this.interests = interests;
    });
  }

  savePicturePost() {
    FirebaseFirestore.instance.collection('wallpaper').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'Image': imageUrl,
      'downloads': 0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'description': commentController.text,
      'category': interests,
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);
    cropImage(pickedFile!.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    cropImage(pickedFile!.path);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage
      (sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
      uploadImage();
    }
  }

  void uploadImage() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: 'Please select an Image');
      return;
    }
    final ref = FirebaseStorage.instance.ref().child('userImages')
        .child('${DateTime.now()}jpg');

    await ref.putFile(imageFile!);
    String path = await ref.getDownloadURL();
    setState(() {
      imageUrl = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[const SliverAppBar(title: Text("Post A Picture",),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body: Column(
              children: <Widget>[
                GestureDetector(
                  onTap:() {
                    showAlert();
                  },
                  child: imageUrl == null ? Image.asset("assets/images/wolf.webp") :
                  Image.network(imageUrl!, width: MediaQuery.of(context).size.width,),),
                Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                  updateInterests(interests);
                },)
                ),
                SizedBox.fromSize(
                    size: const Size(300, 50), // Image radius
                    child: TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(labelText: "Add a title..."),
                    )
                ),
                const SizedBox(height: 10.0,),
                OutlinedButton(
                  onPressed: savePicturePost,
                  child: const Text("Post"),
                )
              ],
            )
        )
    );
  }
}
