import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import  'package:firebase_core/firebase_core.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp>_initialization = Firebase.initializeApp();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot)
      {
        if( snapshot.connectionState == ConnectionState.waiting)
          {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
                home: Scaffold(
                 body: Center(
                  child: Center(
                    child: Text ("Welcome to Student Shared"),
                  ),
                ),
              ), // Scaffold
            );
          }
          else if(snapshot.hasError)
          {
             return const MaterialApp(
               debugShowCheckedModeBanner: false,
              home:Scaffold(
                 body: Center(
                   child: Center(
                      child: Text("An error occured,Please wait"),
               ), //Center
              ), //Center
            ),
         ); // MaterialApp
        }
        return MaterialApp (
          debugShowCheckedModeBanner: false,
          title: "Student Shared",
          home: FirebaseAuth.instance.currentUser == null ? const LoginScreen(): HomeScreen() ,
        ); //MaterialApp
      }
      ); // FutureBuilder
   }
}
