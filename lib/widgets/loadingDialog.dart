import 'package:flutter/material.dart';

Widget getLoading(){
  return WillPopScope(
    onWillPop: () async => false,
    child: const SimpleDialog(
      backgroundColor: Colors.white,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text("Loading"),
              )
            ],
          ),
        )
      ] ,
    ),
  );
}