import 'package:flutter/material.dart';

import '../home_screen/picturesHomescreen.dart';
import '../messagesearch/messagesearch_post.dart';

class Message extends StatefulWidget {


  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple.shade300],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.purple.shade400,
            title: const Center(
              child: Text('Message', style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Signatra",
              ),),
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white,),
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                }
            ),
                  actions: <Widget>[
              IconButton(
              onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => messageSearchPost(),),);
          },
            icon: const Icon(Icons.person_search),
          ),
    ]
              ),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            )
        )
    );
  }
}