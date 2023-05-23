import 'package:flutter/material.dart';
import 'package:sharedstudent1/chat/groupChatScreen.dart';
import 'package:sharedstudent1/widgets/widgets.dart';

import '../groupInfo.dart';

class GroupTile extends StatefulWidget {
  Groups? model;
  BuildContext? context;

   String? userName;
  String? groupId;
   String? groupName;
   String? userImage;
   String? userId;
  GroupTile(
      {Key? key,
        this.model,
        this.context,
         this.groupId,
         this.groupName,
        this.userImage,
         this.userName,
      this.userId})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
             ChatPage(
             groupId: widget.groupId!,
              groupName: widget.groupName!,
              userName: widget.userName!,
               userImage: widget.userImage!,
                 userId: widget.userId!
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red.shade900,
            child: Text(
              widget.groupName!.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.groupName!,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            "Join the conversation as ${widget.userName}",
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ),
    );
  }
}