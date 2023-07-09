import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/widgets/message_tile.dart';

import 'package:sharedstudent1/widgets/widgets.dart';

import '../notification/notification.dart';
import '../notification/server.dart';

import '../widgets/widgets.dart';

import 'DatabasService.dart';
import 'chatWidgets.dart';
import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String userImage;
  String? userId;
   ChatPage(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName,
        required this.userImage,
         this.userId,
      })
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  String? tokens;
  NotificationManager? notificationManager;
  List<String>? members = List.empty(growable: true);
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
    readUserInfo();
    notificationManager = NotificationManager();
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
        body: Container( color: Colors.grey.shade800,child:SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.dimen_8),
                child: Column(children: [
                  chatMessages(),
                  chatbox(),
                ])
            )
        )
        )

    );
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      members = List.from(snapshot.get('members'.substring(0,'members'.indexOf("_"))));
      for(var item in members!){
        await FirebaseFirestore.instance.collection("users")
            .doc(item)
            .get()
            .then((snapshot) async { if (snapshot.exists) {
          setState(() {
            tokens = snapshot.data()!["devicetoken"];
          });
        }
        });
      }
    });
  }
  chatMessages() {
    return Flexible(
        child: StreamBuilder(
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
                    senderImage: snapshot.data.docs[index]['senderImg'],
                    senderId: snapshot.data.docs[index]['senderId']
                );
              },
            )
                : Container();
          },
        )
    );
  }

  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: widget.userName,
      body: action,
    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }
  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "senderImg": widget.userImage,
        "senderId": widget.userId,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      sendNotification(messageController.text);
      setState(() {
        messageController.clear();
      });

    }
  }
}