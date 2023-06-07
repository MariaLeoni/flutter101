import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../categoryView.dart';
import '../home_screen/home.dart';
import '../misc/global.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}
class ProfileScreenState extends State<ProfileScreen> {

  String? name = '';
  String? email = '';
  String? image = '';
  String? phoneNo = '';
  File? imageXFile;
  String? userNameInput = '';
  String? userImageURL;
  bool isFollowing = false;
  Map<String, List<String>?> interests = {};
  TextEditingController deleteTextController = TextEditingController();

  Future getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        name = snapshot.data()!["name"];
        email = snapshot.data()!["email"];
        image = snapshot.data()!["userImage"];
        phoneNo = snapshot.data()!["phoneNumber"];
      });
    }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
  }

  void showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(" Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    getFromCamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                          Icons.camera,
                          color: Colors.black,
                        ),
                      ),
                      Text("Camera",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    getFromGallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                            Icons.image,
                            color: Colors.black
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
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
        imageXFile = File(croppedImage.path);
        updateImageInFirestore();
      });
    }
  }

  Future updateUserName() async {
    bool userExist = await usernameExist(userNameInput!);
    if (userExist){
      Fluttertoast.showToast(msg: "Sorry username $userNameInput already exist.");
      return;
    }
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid).update({
      'name': userNameInput,
    });
  }

  displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Update your name here'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    userNameInput = value;
                  });
                },
                decoration: const InputDecoration(hintText: "Type here"),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateUserName();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white),),
                )
              ]
          );
        }
    );
  }

  void updateImageInFirestore() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref()
        .child("uerImages").child(fileName);
    fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageURL = url;
    });
    await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).update({
      'userImage': userImageURL,
    });
  }

  Future<bool> onBackPressed() async {
    if (interests.isNotEmpty){
      await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'interests': interests,
      });
    }
    return true;
  }

  void updateInterests(Map<String, List<String>?> interests){
    interests.forEach((key, value) {
      if (value == null || value.isEmpty) {
        interests.remove(key);
      }
    });
    this.interests = interests;
  }

  void showDeletionAlert(){
    print("show delete alert");
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: const Text("Are you sure you want to delete your Account?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10.0,),
            const Text("Type delete in the text box below to confirm."),
            const SizedBox(height: 10.0,),
            TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                controller: deleteTextController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type delete...',
                  hintStyle: TextStyle(color: Colors.grey),
                )
            ),
            const SizedBox(height: 20.0,),
            Center(child:  Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0,),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.brown),
                        minimumSize: MaterialStateProperty.all(const Size(100, 40))
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Account Deletion Cancelled")));
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0,),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        minimumSize: MaterialStateProperty.all(const Size(100, 40))
                    ),
                    onPressed: () {
                      if (deleteTextController.text.isNotEmpty && deleteTextController.text.trim() == "delete"){
                        Navigator.of(context, rootNavigator: true).pop();
                        deleteTextController.clear();
                        deleteAccount();
                      }
                      else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Please enter a valid confirmation")));
                      }
                    },
                    child: const Text('Continue'),
                  ),
                )
              ],
            )),
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
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackPressed,
        child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[ SliverAppBar(  flexibleSpace:Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.2],
                    ),
                  ),
                ),title: const Text('Profile', style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontFamily: "Signatra", fontSize: 35),
                ),
                  centerTitle:true, pinned:true, floating:true, ),
                ];
              },
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.black],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.2, 0.9],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10.0,),
                    GestureDetector(
                        onTap: () {
                          showImageDialog();
                        },
                        child: CircleAvatar(
                          radius: 85.0, backgroundImage: imageXFile == null ? NetworkImage(image!) : Image.file(imageXFile!).image,
                        )
                    ),
                    const SizedBox(height: 10.0,),
                    Row(crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Name: ${name!}',
                          style: const TextStyle(fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                      ),
                        IconButton(
                          onPressed: () {
                            displayTextInputDialog(context);
                          },
                          icon: const Icon(Icons.edit, color:Colors.white),
                        )
                      ],
                    ),
                    const SizedBox( height: 10.0,),
                    Text('Email: ${email!}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox( height: 5.0,),
                    Text('Phone Number: ${phoneNo!}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    Flexible(child: CategoryView(interestCallback: (Map<String, List<String>?> interests) {
                      updateInterests(interests);
                    }, isEditable: true,)
                    ),
                    ElevatedButton(
                        onPressed:() {
                          signOutUser();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        child: const Text("Logout")
                    ),
                    ElevatedButton(
                        onPressed:() {
                          print("delete pressed");
                          showDeletionAlert();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        child: const Text("Delete Account")
                    )
                  ],
                ),
              ),
            ))
    );
  }

  void deleteAccount() {
    var requestDate = DateTime.now();

    var user = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    user.update({
      'active': false
    }).then((value) => print("deleted"))
        .onError((error, stackTrace) => print("delete account error ${error.toString()}"));

    user.set({
      'requestDate': requestDate
    }, SetOptions(merge: true));

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  const LoginScreen()) );
  }
}


