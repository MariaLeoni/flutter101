import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/forgot_password/forgot_password.dart';
import 'package:sharedstudent1/home_screen/picturesHomescreen.dart';
import 'package:sharedstudent1/widgets/input_field.dart';

import '../../VerifyEmail/VerifyEmail.dart';
import '../../account_check/account_check.dart';
import '../../sign_up/sign_up_screen.dart';
import '../../widgets/button_square.dart';

class Credentials extends StatelessWidget {
  final FirebaseAuth _auth  = FirebaseAuth.instance;

  final  TextEditingController _emailTextController = TextEditingController(text:'');
  final TextEditingController _passTextController = TextEditingController(text: '');
  final mounted = true;

  Credentials({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Padding(padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: CircleAvatar(
                radius: 130,
                backgroundColor: Colors.red,
                child: CircleAvatar(
                  radius: 120,
                  backgroundImage: AssetImage('assets/images/wolf.webp'),
                ),
              )),
              const SizedBox(height: 15.0,),
              InputField(
                hintText: "Enter Email",
                icon: Icons.email,
                obscureText: false,
                textEditingController: _emailTextController,
              ),
              const SizedBox(height: 8.0,),
              InputField(
                hintText: "Enter Password",
                icon: Icons.lock,
                obscureText: true,
                textEditingController: _passTextController,
              ),
              const SizedBox(height: 12.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                      },
                      child: const Text("Forgot Password?",
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
                          password: _passTextController.text.trim());

                      if (!mounted) return;
                      User? me = _auth.currentUser;
                      if (me != null && me.emailVerified) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                      }
                      else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Please verify your email address and try again")));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> VerifyEmail()));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'wrong-password') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("The password provided is wrong.")));
                      }
                      else if (e.code == 'invalid-email') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Looks like email provided is not valid.")));
                      }
                      else if (e.code == 'user-not-found') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("No account found for this email. Please check details and try again.")));
                      }
                      else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("An error has occurred. Please check details and try again.")));
                      }
                    }
                    catch(error) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("An error has occurred. Please check details and try again.")));
                    }
                  }
              ),
              AccountCheck(login: true, press:() {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
              }
              )
            ],
          ),
        )
    );
  }
}
