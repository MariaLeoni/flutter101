import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharedstudent1/account_check/account_check.dart';
import 'package:sharedstudent1/sign_up/sign_up_screen.dart';
import 'package:sharedstudent1/widgets/input_field.dart';

import '../../log_in/login_screen.dart';
import '../../widgets/button_square.dart';

class Credentials extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

final TextEditingController _emailTextController = TextEditingController(text:'');

  Credentials({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Center(
              child: Image.asset(
                "assets/images/forget.png",
                width: 300.0,
              ),
            ),
          ),
            const SizedBox( height:10.0,),
          InputField(
            hintText: "Enter Email",
            icon:Icons.email_rounded,
            obscureText: false,
            textEditingController: _emailTextController,
          ),
          const SizedBox(height:15.0),
          ButtonSquare(
            text:"Send Link",
            colors1: Colors.red,
            colors2: Colors.redAccent,

            press:() async
              {
                try
                    {
                      await _auth.sendPasswordResetEmail(email: _emailTextController.text);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.amber,
                        content: Text("Password reset email has been sent!",
                        style: TextStyle(fontSize: 10.0),),
                      ),
                      );
                    }
                    on FirebaseAuthException catch (error)
                {
                  Fluttertoast.showToast(msg: error.toString());
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder:(_) => const LoginScreen()));
              }
          ),

          TextButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
            child: const Center(child: Text("Create Account")),
          ),
          AccountCheck(
            login: false,
            press:()
              {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
          )
        ],
      )
    );
  }
}
