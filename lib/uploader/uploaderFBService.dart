import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sharedstudent1/misc/global.dart';

class FBUploaderService{

  String? myImage;
  String? myName;
  File? videoFile;
  String? postUrl;
  File? imageFile;
  String title = "";
  String postId = "";
  Map<String, List<String>?> interests = {};

  FBUploaderService({this.myImage, this.myName, this.videoFile, this.imageFile,
    required this.title, required this.postId, required this.selectedInterests});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> selectedInterests = List.empty(growable: true);


  File uploadVideoFile = File("");

  postVideo() {
    FirebaseFirestore.instance.collection('wallpaper2').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'video': postUrl,
      'downloads': 0,
      'viewcount': 0,
      'viewers': <String>[],
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'description': title,
      'category': selectedInterests,
    });
  }

  postPicture() {
    FirebaseFirestore.instance.collection('wallpaper').doc(postId).set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'Image': postUrl,
      'downloads': 0,
      'viewcount': 0,
      'createdAt': DateTime.now(),
      'postId': postId,
      'likes': <String>[],
      'viewers': <String>[],
      'description': title,
      'category': selectedInterests,
    });
  }

  void uploadPost(PostType postType) async {

    interests.forEach((key, value) {
      if (value != null) {
        selectedInterests.addAll(value);
      }
    });

    try {
      if (postType == PostType.video){
        final ref = FirebaseStorage.instance.ref().child('userVideos').child('${DateTime.now()}.mp4');
        uploadVideoFile = await getProcessedFile(videoFile) ?? uploadVideoFile;

        await ref.putFile(uploadVideoFile);
        postUrl = await ref.getDownloadURL();
        postVideo();
      }
      else if (postType == PostType.image){

        final ref = FirebaseStorage.instance.ref().child('userImages')
            .child('${DateTime.now()}jpg');
        await ref.putFile(imageFile!);
        postUrl = await ref.getDownloadURL();

        postPicture();
      }
    }
    catch(error) {
      print("Upload error ${error.toString()}");
    }
  }
}