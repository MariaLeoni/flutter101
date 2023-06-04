import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/groupInfo.dart';
import 'package:sharedstudent1/widgets/widgets.dart';
import '../chat/groupChatScreen.dart';

class SearchGroupTile extends StatefulWidget {
  Groups? model;
  BuildContext? context;
  String? userName;
  SearchGroupTile({super.key, this.model, this.context,});

  @override
  State<SearchGroupTile> createState() => _SearchGroupTileState();
}

class _SearchGroupTileState extends State<SearchGroupTile> {
  String? userName;

  @override
  void initState() {
    super.initState();
    getDataFromDatabase();

  }
  void getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        userName = snapshot.data()!["name"];
      });
    }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.model!.groupId!,
              groupName: widget.model!.groupName!,
              userName: userName!, userImage: '',
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.model!.groupName!.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.model!.groupName!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversation as ${userName}",
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}