import 'package:flutter/material.dart';
import'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharedstudent1/InitialCategories.dart';
<<<<<<< HEAD
import 'package:sharedstudent1/categoryView.dart';
import 'package:sharedstudent1/home_screen/picturesHomescreen.dart';
=======
>>>>>>> 46cb45c47932004d8bc81109282cdf8eee9fc933
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';


class VerifyEmail extends StatefulWidget {


  @override
  VerifyEmailState createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;
  @override
  initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified(),);
    }
    else{
      const LoginScreen();
    }
  }

  @override
  void dispose() {
    timer?. cancel();
    super.dispose();
  }

  Future checkEmailVerified() async{
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds:5));
      setState(() => canResendEmail = true);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }


  @override
  Widget build(BuildContext context) =>
      isEmailVerified ? InitialCategories(): Scaffold(
          appBar: AppBar(
            title: const Text('Verify Email'),
          ),
          body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    const Text(
                      'A verification email has been sent to your email',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,),
                    const SizedBox(height:24),
                    ElevatedButton.icon(
                      style:ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.email, size:32),
                      label: const Text(
                        'Resend Email',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: canResendEmail? sendVerificationEmail:null,
                    ),
                    const SizedBox(height:8),
                    TextButton(
                      style:ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    )
                  ]
              )
          )
      );
}
