import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:sharedstudent1/search_post/users_specifics_page.dart';
import 'package:uuid/uuid.dart';
import '../categoryView.dart';
import '../home_screen/picturesHomescreen.dart';
import '../home_screen/videosHomescreen.dart';
import '../misc/progressIndicator.dart';
import '../misc/userModel.dart';
import '../vidlib/chewieVideoWidget.dart';
import '../widgets/input_field.dart';

class PostUploader extends StatefulWidget {

  PostType? postType;
  String category = "";
  UserWithNameAndId? user;
  PostUploader({super.key, this.postType, required this.category, this.user });

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
  File uploadVideoFile = File("");

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
    Navigator.push(context, MaterialPageRoute(builder: (_) =>  UsersSpecificPostsScreen(userId: _auth.currentUser!.uid, userName: myName!, postType: PostType.video,),),);

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
                cameraSource(context);
              },
              child: const Row(
                children: [
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
                gallerySource(context);
              },
              child: const Row(
                children: [
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

  void getImageFromCamera(BuildContext context) async {
    await requestPermission(Permission.camera, (permissionStatus) async {
      if (permissionGranted(permissionStatus)) {
        XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.camera);
        cropImage(pickedFile!.path);
        if (!mounted) return;
        Navigator.pop(context);
      }
      else{
        openAppSettings();
      }
    });
  }

  void getImageFromGallery(BuildContext context) async {
    await requestPermission(Permission.storage, (permissionStatus) async {
      if (permissionGranted(permissionStatus)) {
        XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery);
        cropImage(pickedFile!.path);

        if (!mounted) return;
        Navigator.pop(context);
      }
      else{
        openAppSettings();
      }
    });
  }

  void cameraSource(BuildContext context){
    if (widget.postType == PostType.video){
      getVideoFromCamera(context);
    }
    else {
      getImageFromCamera(context);
    }
  }

  void gallerySource(BuildContext context){
    if (widget.postType == PostType.video){
      getVideoFromGallery(context);
    }
    else {
      getImageFromGallery(context);
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

  void getVideoFromCamera(BuildContext context) async {
    await requestPermission(Permission.camera, (permissionStatus) async{
      if (permissionGranted(permissionStatus)){
        XFile? pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            videoFile = File(pickedFile.path);
            setVideo();
          });

          if (!mounted) return;
          Navigator.pop(context);
        }
      }
      else{
        openAppSettings();
      }
    });
  }

  void getVideoFromGallery(BuildContext context) async {
    await requestPermission(Permission.storage, (permissionStatus) async {
      if (permissionGranted(permissionStatus)){
        XFile? pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            videoFile = File(pickedFile.path);
            setVideo();
          });

          if (!mounted) return;
          Navigator.pop(context);
        }
      }
      else{
        openAppSettings();
      }
    });
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Your video is being uploaded...")));

        if (widget.user == null){
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              VideoHomeScreen.forCategory(category: widget.category,),),);
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage()));
        }

        final ref = FirebaseStorage.instance.ref().child('userVideos').child('${DateTime.now()}.mp4');
        uploadVideoFile = await getProcessedFile(videoFile) ?? uploadVideoFile;

        await ref.putFile(uploadVideoFile);
        String path = await ref.getDownloadURL();
        setState(() {
          postUrl = path;
          postVideo();
        });
      }
      else if (widget.postType == PostType.image){
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Your image is being uploaded...")));

        if (widget.user == null){
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              PictureHomeScreen.forCategory(category: widget.category,),),);
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (_) => PictureHomeScreen.forUser(user: widget.user,)));
        }

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
      print("Upload error ${error.toString()}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
                title: Text(title,),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body: Container(color: Colors.black,
              child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0,),
                GestureDetector(
                    onTap:() {
                      showAlert();
                    },
                    child: widget.postType == PostType.video ? (videoFile == null ? SizedBox (height: 100, child: Image.asset("assets/images/TheGist.png")) :
                    SizedBox.fromSize(size: const Size(500.0,  400), // Image border
                        child: ChewieVideoWidget(autoPlayAndFullscreen: false, url: videoFile!.path, file: videoFile,)
                    )) : (imageFile == null ? Image.asset("assets/images/TheGist.png", height:410,) :
                    Image.file(imageFile!, height: 350,))),
                Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                  updateInterests(interests);
                }, isEditable: false,)
                ),
                SizedBox.fromSize(size: const Size(350.0,  80),
                    child:
                    InputField(
                      textEditingController: commentController, hintText: "Add a description...", icon: Icons.post_add,
                       obscureText: false,
                    )
                ),
                const SizedBox(height: 10.0,),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade900),
                      minimumSize: MaterialStateProperty.all(const Size(150, 50))
                  ),
                  onPressed: uploadPost,
                  child: const Text('Post'),
                ),
                const SizedBox(height: 30.0,),
              ],
            ),)
        )
    );
  }
}
