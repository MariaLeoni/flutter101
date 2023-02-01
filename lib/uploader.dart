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
import 'home_screen/homescreen.dart';

class Uploader extends StatefulWidget {

  String? imageFrom;
  Uploader({super.key, this.imageFrom,});

  @override
  State<Uploader> createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  TextEditingController commentController = TextEditingController();
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? myImage;
  String? myName;
  File? imageFile;
  String? imageUrl;

  addComment() {
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
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    if (!mounted) return;
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    widget.imageFrom = null;
  }

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

    // Timer.run(() {
    //   showGeneralDialog(
    //     barrierDismissible: true,
    //     barrierLabel: '',
    //     barrierColor: Colors.black38,
    //     transitionDuration: const Duration(milliseconds: 500),
    //     pageBuilder: (ctx, anim1, anim2) => AlertDialog(
    //       title: const Text("Please choose an option"),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           InkWell(
    //             onTap: () {
    //               getFromCamera();
    //             },
    //             child: Row(
    //               children: const [
    //                 Padding(
    //                   padding: EdgeInsets.all(4.0,),
    //                   child: Icon(Icons.camera, color: Colors.red,),
    //                 ),
    //                 Text("Camera", style: TextStyle(color: Colors.black),),
    //               ],
    //             ),
    //           ),
    //           InkWell(
    //             onTap: () {
    //               getFromGallery();
    //             },
    //             child: Row(
    //               children: const [
    //                 Padding(
    //                   padding: EdgeInsets.all(4.0,),
    //                   child: Icon(Icons.image, color: Colors.redAccent,),
    //                 ),
    //                 Text("Gallery", style: TextStyle(color: Colors.black),),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
    //       filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
    //       child: FadeTransition(
    //         opacity: anim1,
    //         child: child,
    //       ),
    //     ),
    //     context: context,
    //   );
    // });
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
                  children: <Widget>[imageUrl == null ?
                  Image.asset("assets/images/wolf.webp") :
                  Image.network(imageUrl!, width: MediaQuery.of(context).size.width,),
                    const Divider(),
                    ListTile(
                        title: TextFormField(
                          controller: commentController,
                          decoration: const InputDecoration(labelText: "Add a description..."),
                        ),
                        trailing: OutlinedButton(
                          onPressed: addComment,
                          child: const Text("Post"),
                        )
                    ),
                  ],
                )
            )
        )
    );
  }
}
