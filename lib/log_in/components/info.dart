import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharedstudent1/forgot_password/forgot_password.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/widgets/input_field.dart';

import '../../account_check/account_check.dart';
import '../../sign_up/sign_up_screen.dart';
import '../../widgets/button_square.dart';

class Credentials extends StatelessWidget {
  final FirebaseAuth _auth  = FirebaseAuth.instance;


  final  TextEditingController _emailTextController = TextEditingController(text:'');
 final TextEditingController _passTextController = TextEditingController(text: '');

  Credentials({super.key});

 @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: 140,
                backgroundImage: AssetImage('assets/images/wolf.webp'),
              ),
            )
          ),
          const SizedBox(height: 15.0,),
          InputField(
            hintText: "Enter Email",
            icon: Icon(Icons.email_rounded, color: ,)s.email_rounded,
            obscureText: false,
            textEditingController: _emailTextController,
          ),
          const SizedBox(height: 15.0,),
          InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obscureText: true,
            textEditingController: _passTextController,
          ),
          const SizedBox(height: 15.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: ()
                  {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 17
                    )
                  )
              )
            ],
          ),
          ButtonSquare(
            text:"Login",
            colors1: Colors.purple,
            colors2: Colors.red,

            press:() async{
              try{
                await _auth.signInWithEmailAndPassword(
                  email: _emailTextController.text.trim().toLowerCase(),
                  password: _passTextController.text.trim(),



                );
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              }catch(error)
               {
                 Fluttertoast.showToast(msg: error.toString());
               }
            }
          ),
          AccountCheck(
            login: true,
            press:()
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
            }
          )
        ],
      ),
    );
  }
}
