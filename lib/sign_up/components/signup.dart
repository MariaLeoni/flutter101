import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/account_check/account_check.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:sharedstudent1/widgets/button_square.dart';
import 'package:sharedstudent1/widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../VerifyEmail/VerifyEmail.dart';
import '../../home_screen/homescreen.dart';
import '../../misc/global.dart';
import '../sign_up_screen.dart';

class Credentials extends StatefulWidget {
  const Credentials({super.key});


  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _fullNameController = TextEditingController(
      text: "");
  final TextEditingController _emailTextController = TextEditingController(
      text: "");
  final TextEditingController _passTextController = TextEditingController(
      text: "");
  final TextEditingController _phoneNumController = TextEditingController(
      text: "");

  File? imageFile;
  String? imageUrl;


  void _showImageDialog() {
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
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                          Icons.camera,
                          color: Colors.redAccent,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                            Icons.image,
                            color: Colors.redAccent
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

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage
      (sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageDialog();
                },
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: imageFile == null ?
                  const AssetImage("assets/images/login.jpg") :
                  Image.file(imageFile!).image,
                ),
              ),
              const SizedBox(height: 10.0,),
              InputField(
                hintText: " Enter username",
                icon: Icons.person,
                obscureText: false,
                textEditingController: _fullNameController,
              ),
              const SizedBox(height: 10.0,),
              InputField(
                hintText: "Enter Email",
                icon: Icons.email_rounded,
                obscureText: false,
                textEditingController: _emailTextController,
              ),
              const SizedBox(height: 10.0,),
              InputField(
                hintText: "Enter Password",
                icon: Icons.lock,
                obscureText: true,
                textEditingController: _passTextController,
              ),
              const SizedBox(height: 10.0,),
              InputField(
                hintText: "Enter Phone Number",
                icon: Icons.phone,
                obscureText: false,
                textEditingController: _phoneNumController,
              ),
              const SizedBox(height: 15.0,),
              ButtonSquare(text: "Create Account",
                  colors1: Colors.red, colors2: Colors.redAccent,
                  press: () async {

                    try {
                      imageFile ??= await copyAssetToLocal("images/login.jpg");

                      final ref = FirebaseStorage.instance.ref()
                          .child('userImages').child('${DateTime.now()}.jpg');

                      await ref.putFile(imageFile!);
                      imageUrl = await ref.getDownloadURL();

                      await _auth.createUserWithEmailAndPassword(
                        email: _emailTextController.text.trim().toLowerCase(),
                        password: _passTextController.text.trim(),);

                      final User? user = _auth.currentUser;
                      final uid = user!.uid;

                      FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'id': uid,
                        'userImage': imageUrl,
                        'name': _fullNameController.text,
                        'email': _emailTextController.text,
                        'phoneNumber': _phoneNumController.text,
                        'CreateAt': Timestamp.now(),
                        'followers': <String>[],
                      });
                      if (!mounted) return;
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> VerifyEmail()));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        Fluttertoast.showToast(msg: "The password provided is too weak.");
                      } else if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(msg: "An account exists for this email. Please log in");
                        Navigator.canPop(context) ? Navigator.pop(context) : null;
                      }
                    } catch (error) {
                      Fluttertoast.showToast(msg: error.toString());
                    }
                  }
              ),
              AccountCheck(
                login: false,
                press: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const LoginScreen()));
                },
              )
            ],
          ),
        )
    );
  }
}