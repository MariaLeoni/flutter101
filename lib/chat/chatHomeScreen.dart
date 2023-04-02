import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chathome.dart';
import '../home_screen/home.dart';
import '../profile/profile_screen.dart';
import 'chatListScreen.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => ChatHomeScreenState();
}

class ChatHomeScreenState extends State<ChatHomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.chat_bubble),),
              Tab(icon: Icon(Icons.group_outlined),),
              Tab(icon: Icon(Icons.star),)
            ],),
            title: const Text('Chats'),
            actions: [
              IconButton(
                  onPressed: (){
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                   },
                  icon: const Icon(Icons.home)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  icon: const Icon(Icons.person)),
            ]),
        body: TabBarView(children: [
            ChatListScreen(chatees: List.empty(),),
            ChatHome(),
            ChatHome()
        ],),
    ));
  }


}