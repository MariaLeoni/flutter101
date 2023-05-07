import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_screen/home.dart';
import '../profile/profile_screen.dart';
import 'chatListScreen.dart';
import 'groupChatHome.dart';
import 'moodHomeScreen.dart';

class SocialHomeScreen extends StatefulWidget {
  const SocialHomeScreen({super.key});

  @override
  State<SocialHomeScreen> createState() => SocialHomeScreenState();
}

class SocialHomeScreenState extends State<SocialHomeScreen> {
  String pageTitle = "Chats";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Builder(builder: (BuildContext context) {
          final TabController? controller = DefaultTabController.of(context);
          controller?.addListener(() {
            if (!controller.indexIsChanging) {
              if (controller.index == 1){
                pageTitle = "Groups";
              }
              else if (controller.index == 2){
                pageTitle = "Moods";
              }
              else{
                pageTitle = "Chats";
              }
              setState(() {
                pageTitle;
              });
            }
          });
          return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                flexibleSpace: Container(
                  color: Colors.grey.shade800
                ),
                bottom: const TabBar(tabs: [
                  Tab(icon: Icon(Icons.chat_bubble),),
                  Tab(icon: Icon(Icons.group_outlined),),
                  Tab(icon: Icon(Icons.emoji_emotions_rounded),)
                ],),
                title: Text(pageTitle),
                actions: [
                  IconButton(
                      onPressed: () {
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
            body:Container(color:Colors.black,child: TabBarView(children: [
              ChatListScreen(chatees: List.empty(),),
              GroupChatHome(),
              const MoodScreen()
            ],),
          ));
        })
    );
  }
}