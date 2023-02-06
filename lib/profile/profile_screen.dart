import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';

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
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                          Icons.camera,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text("Camera",
                        style: TextStyle(color: Colors.purple),
                      ),
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
                        child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.purple),
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
              title: const Text('Update your name Here'),
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
                    primary: Colors.red,
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
                    primary: Colors.amber,
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white),),
                )
              ]
          );
        }
    );
  }

  void updateImageInFirestore() async
  {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          title: const Center(
            child: Text('Profile', style: TextStyle(
              fontSize: 35,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: "Signatra",
            ),),
          ),
          leading: IconButton(
              icon:const Icon(Icons.arrow_back, color: Colors.white,),
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              }
          )
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple.shade300],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showImageDialog();
              },
              child: CircleAvatar(backgroundColor: Colors.amberAccent,
                minRadius: 90.0,
                child: CircleAvatar(
                  radius: 85.0, backgroundImage: imageXFile == null ?
                  NetworkImage(image!) : Image.file(imageXFile!).image,
                ),
              ),
            ),
            const SizedBox(height: 10.0,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
            const SizedBox( height: 10.0,),
            Text('Email: ${email!}',
              style: const TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox( height: 20.0,),
            Text('Phone Number: ${phoneNo!}',
              style: const TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox( height: 10.0,),
            ElevatedButton(
                onPressed:() {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.amberAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text("Logout")
            )
          ],
        ),
      ),
    );
  }
}
