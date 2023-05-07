import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/widgets/message_tile.dart';
import 'package:sharedstudent1/widgets/widgets.dart';

import 'DatabasService.dart';
import 'chatWidgets.dart';
import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String userImage;
  const ChatPage(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName,
        required this.userImage,
      })
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }
  Widget chatbox() {

    var screen = MediaQuery.of(context).size;
    return SizedBox(
        width: screen.width,
        height: 60,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_8),
            child:Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.dimen_30),
                color: Colors.grey.shade700,
              ),
              child: Row(
                children: [
                  // Container(
                  //   margin: const EdgeInsets.only(right: Sizes.dimen_4),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.greyColor,
                  //     borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  //   ),
                  //   child: IconButton(
                  //     onPressed: sendMessage,
                  //     icon: const Icon(Icons.add_a_photo, size: Sizes.dimen_18,
                  //     ),
                  //     color: AppColors.white,
                  //   ),
                  // ),
                  Flexible(child: TextField(
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: messageController,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Type here...',
                        hintStyle: TextStyle(color: AppColors.white)),

                    style: const TextStyle(
                        color: Colors.white),
                  )),
                  // Container(
                  //   margin: const EdgeInsets.only(left: Sizes.dimen_4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.red.shade900,
                  //     borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  //   ),
                  //   child: IconButton(
                  //     onPressed: () {
                  //       sendMessage();
                  //     },
                  //     icon: const Icon(Icons.send_rounded),
                  //     color: AppColors.white,
                  //   ),
                  // ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.white,
                  ),
                ],
              ),
            )
        ));
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Column( children: [chatMessages(),chatbox(), ])
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sentByMe: widget.userName ==
                    snapshot.data.docs[index]['sender'],
              senderImage: snapshot.data.docs[index]['senderImg']
            );
          },
        )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "senderImg": widget.userImage,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}