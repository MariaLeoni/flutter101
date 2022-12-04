import 'package:flutter/material.dart';

class  TextFieldContainer extends StatelessWidget {

  final Widget child;

  const TextFieldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 15.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blueAccent,Colors.white,]
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            offset: Offset(-2,-2),
            spreadRadius: 1,
            blurRadius: 4,
            color: Colors.white,
          ),
          BoxShadow(
            offset: Offset(2,2),
            spreadRadius: 1,
            blurRadius: 4,
            color: Colors.blueAccent,
          )
        ]
      ),
      child: child,
    );
  }
}
