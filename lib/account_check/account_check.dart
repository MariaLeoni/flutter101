import 'package:flutter/material.dart';

class AccountCheck extends StatelessWidget {

  final bool login;
  final VoidCallback press;

  const AccountCheck({super.key, required this.login, required this.press});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        Text(
          login? "No account?" : "Have an Account?",
          style: const TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        const SizedBox(width: 10.0,),
        GestureDetector(
          onTap:press,
          child:Text(
            login? "Create Account": "Log In",
            style: const TextStyle( fontSize:18.0, color:Colors.blue, fontWeight: FontWeight.bold)
          )
        ),
        const SizedBox(height: 50.0,),
      ],
    );
  }
}
