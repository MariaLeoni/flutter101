import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import  'package:firebase_core/firebase_core.dart';
import 'package:sharedstudent1/home_screen/picturesHomescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';

import 'home_screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp().whenComplete(() {
    runApp( MyApp());
  });
}
final themeMode = ValueNotifier(2);

class MyApp extends StatelessWidget {

  const MyApp({super.key,});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebase = FirebaseAuth.instance;
    bool allowUser = false;

    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text("Welcome to Student Shared", style: TextStyle(fontSize: 28.0,
                        color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ), // Scaffold
            );
          }
          else if (snapshot.hasError) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text("An error occurred, Please wait"),
                  ), //Center
                ), //Center
              ),
            ); // MaterialApp
          }

          User? me = firebase.currentUser;
          if (me != null && me.emailVerified) {
            allowUser = true;
          }

          return MaterialApp(debugShowCheckedModeBanner: false,
            title: "Student Shared",
            home: allowUser ? HomeScreen() : const LoginScreen(),
          );// MaterialApp
        }
    ); // FutureBuilder
  }
}
