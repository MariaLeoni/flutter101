import 'package:flutter/material.dart';
import'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:sharedstudent1/sign_up/sign_up_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';


class VerifyEmail extends StatefulWidget {


  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;
  @override
   initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
          (_) => checkEmailVerified(),
      );
    }
    else{
       LoginScreen();
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
      await Future.delayed(Duration(seconds:5));
      setState(() => canResendEmail = true);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

    @override
    Widget build(BuildContext context) =>
        isEmailVerified
            ? HomeScreen()
            : Scaffold(
          appBar: AppBar(
            title: Text('Verify Email'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Text(
                'A verification email has been sent to your email',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,),
                SizedBox(height:24),
                ElevatedButton.icon(
                  style:ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50),
                  ),
                  icon: Icon(Icons.email, size:32),
                  label: Text(
                    'Resend Email',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: canResendEmail? sendVerificationEmail:null,
                ),
                SizedBox(height:8),
            TextButton(
                  style:ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50),
                  ),
                  child: Text(
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
