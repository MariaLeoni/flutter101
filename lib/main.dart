import 'dart:async';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import  'package:firebase_core/firebase_core.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'home_screen/home.dart';
import 'notification/server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch other errors e.g inside button press
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp().whenComplete(() {

      // Pass all uncaught errors from the framework to Crashlytics.
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      runApp(const MyApp());
    });

  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

  // Catch errors outside Flutter
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
}
final themeMode = ValueNotifier(2);

class MyApp extends StatelessWidget {

  const MyApp({super.key,});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebase = FirebaseAuth.instance;
    FirebaseCrashlytics.instance.setUserIdentifier(firebase.currentUser?.uid ?? "NotRegistered");
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
                    child: Text("Welcome to TheGist", style: TextStyle(fontSize: 28.0,
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

          NotificationManager().alertForNotificationPermission();

          return MaterialApp(debugShowCheckedModeBanner: false,
            title: "TheGist",
            home: allowUser ? const HomeScreen() : const LoginScreen(),
          );// MaterialApp
        }
    ); // FutureBuilder
  }
}
