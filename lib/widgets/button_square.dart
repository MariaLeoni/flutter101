import 'package:flutter/material.dart';

class ButtonSquare extends StatelessWidget {

  final String text;
  final VoidCallback press;
  final Color colors1;
   final Color colors2;

   const ButtonSquare({super.key,
    required this.text,
     required this.press,
     required this.colors1,
     required this.colors2,
});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.only(top:6.0, bottom:6.0),
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin:Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.red,]

            ),
            boxShadow:const [
            BoxShadow(
              offset: Offset(3,3),
              spreadRadius:1,
              blurRadius: 2,
              color: Colors.red,
            ) ,
            BoxShadow(
              offset: Offset(-5,-5),
              spreadRadius: 1,
              blurRadius: 2,
              color: Colors.black,
            ),
           ]
          ),
          child: Center(
            child:Text(
              text,
              style: const TextStyle(
               fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )
            )
          ),
        ),
      )
    );
  }
}
