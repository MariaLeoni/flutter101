import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../VerifyEmail/VerifyEmail.dart';
import '../../account_check/account_check.dart';
import '../../log_in/login_screen.dart';
import '../../misc/global.dart';
import '../../search_post/user.dart';
import '../../widgets/button_square.dart';
import '../../widgets/inappwebview.dart';
import '../../widgets/input_field.dart';

class Credentials extends StatefulWidget {
  const Credentials({super.key});


  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _fullNameController = TextEditingController(text: "");
  final TextEditingController _emailTextController = TextEditingController(text: "");
  final TextEditingController _passTextController = TextEditingController(text: "");
  final TextEditingController _phoneNumController = TextEditingController(text: "");

  File? imageFile;
  String? imageUrl;
  bool agreed = false;

  final Map<String, List<String>?> interests = {};

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
                  child: const Row(
                    children: [
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
                  child: const Row(
                    children: [
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
    await requestPermission(Permission.camera, (permissionStatus) async{
      if (permissionGranted(permissionStatus)) {
        XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.camera);
        _cropImage(pickedFile!.path);
        if (!mounted) return;
        Navigator.pop(context);
      }
      else{
        openAppSettings();
      }
      });
  }

  void _getFromGallery() async {
    await requestPermission(Permission.storage, (permissionStatus) async {
      if (permissionGranted(permissionStatus)) {
        XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery);
        _cropImage(pickedFile!.path);
        if (!mounted) return;
        Navigator.pop(context);
      }
    });
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
                hintText: "Enter username",
                icon: Icons.person,
                obscureText: false,
                textEditingController: _fullNameController,
              ),
              InputField(
                hintText: "Enter Email",
                icon: Icons.email_rounded,
                obscureText: false,
                textEditingController: _emailTextController,
              ),
              InputField(
                hintText: "Enter Password",
                icon: Icons.lock,
                obscureText: true,
                textEditingController: _passTextController,
              ),
              InputField(
                hintText: "Enter Phone Number",
                icon: Icons.phone,
                obscureText: false,
                textEditingController: _phoneNumController,
              ),
              const SizedBox(height: 15.0,),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => InAppWebViewPage("https://campus100.web.app/thegisteula.html", "TheGist EULA")));
                  },
                  child: const Text("Read our EULA", style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Bebas",
                  ),),
                ),
              ),
              const SizedBox(height: 10.0,),
              Center(child: CheckboxListTile(
                  title: const Text("Agreed to our EULA?", style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Bebas",
                  ),),
                  value: agreed,
                  onChanged: (newValue) {
                    setState(() {
                      agreed = newValue ?? false;
                    });
                  },
                  tileColor: Colors.redAccent,
                  checkColor: Colors.black,
                  checkboxShape: const BeveledRectangleBorder(),
                ),
              ),
              const SizedBox(height: 15.0,),
              ButtonSquare(text: "Create Account",
                  colors1: Colors.red, colors2: Colors.redAccent,
                  press: () async {
                    if (agreed == false){
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("You need to read and agree to our EULA to continue")));
                      return;
                    }
                    if (_fullNameController.text.isEmpty){
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("User name is required")));
                      return;
                    }

                    bool userExist = await usernameExist(_fullNameController.text.trim());
                    if (userExist){
                        Users? user = await getUserWithEmail(_emailTextController.text.trim().toLowerCase());
                        if (user != null && user.active == false) {
                          //Its more than a week since user requested to delete account.
                          // Let's delete and ask them to create an account
                          deleteUser(user);
                        }
                        else{
                          if (!mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("Sorry username ${_fullNameController.text.trim()} already exist.")));
                          return;
                        }
                    }

                    try {
                      imageFile ??= await getImageFileFromAssets("images/login.jpg");

                      final ref = FirebaseStorage.instance.ref()
                          .child('userImages').child('${DateTime.now()}.jpg');

                      await ref.putFile(imageFile!);
                      imageUrl = await ref.getDownloadURL();

                      await _auth.createUserWithEmailAndPassword(
                        email: _emailTextController.text.trim().toLowerCase(),
                        password: _passTextController.text.trim());

                      final User? user = _auth.currentUser;
                      final uid = user!.uid;

                        var token = await FirebaseMessaging.instance.getToken();
                        setState(() {
                          token = token;
                        });

                      FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'id': uid,
                        'userImage': imageUrl,
                        'name': _fullNameController.text,
                        'email': _emailTextController.text,
                        'phoneNumber': _phoneNumController.text,
                        'CreateAt': Timestamp.now(),
                        'followers': <String>[],
                        'following':<String>[],
                        'categories': interests,
                        'token':token,
                        'groups':<String>[],
                        'active': true,
                       });
                      if (!mounted) return;
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> VerifyEmail()));
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("The password provided is too weak.")));
                      }
                      else if (e.code == 'invalid-email') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Looks like email provided is not valid")));
                      }
                      else if (e.code == 'email-already-in-use') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("An account exists for this email. Please log in.")));
                        Navigator.canPop(context) ? Navigator.pop(context) : null;
                      }
                      else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("An error has occurred. Please check details and try again.")));
                      }
                    } catch (error) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("An error has occurred. Please check details and try again.")));
                    }
                  }
              ),
              AccountCheck(login: false, press: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const LoginScreen()));
                },
              )
            ],
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
  }
}