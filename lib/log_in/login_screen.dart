import'package:flutter/material.dart';
import 'components/heading_text.dart';
import 'components/login.dart';
import 'package:firebase_admin/firebase_admin.dart' as fadmin;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  adminWorkTest() async {
    const cId = "462259146837-c8jqjh7t2uk9dmu9gncbe4ro4un4i7vc.apps.googleusercontent.com";
    const cSec = "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";
    var credential = fadmin.Credentials.applicationDefault();

    // when no credentials found, login using openid
    // the credentials are stored on disk for later use
    // either set the parameters clientId and clientSecret of the login method or
    // set the env variable FIREBASE_CLIENT_ID and FIREBASE_CLIENT_SECRET
    credential ??= await fadmin.Credentials.login(clientId: cId, clientSecret: cSec);

    var projectId = 'studentshared1';
    // create an app
    var app = fadmin.FirebaseAdmin.instance.initializeApp(fadmin.AppOptions(
        credential: credential,
        projectId: projectId,
        storageBucket: '$projectId.appspot.com'));

    try {
      // get a user by email
      var v = await app.auth().getUserByEmail('jonas.boateng01@gmail.com');
      print("User found ${v.toJson()}");
    } on fadmin.FirebaseException catch (e) {
      print("Admin SDK error ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    adminWorkTest();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black12, Colors.black],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const HeadText(),
                Credentials(),
            ],
      ),
      ),
      ),
      ),
    );
  }
}
