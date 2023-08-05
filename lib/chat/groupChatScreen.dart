import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/widgets/message_tile.dart';
import 'package:sharedstudent1/widgets/widgets.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import 'DatabasService.dart';
import 'chatWidgets.dart';
import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String userImage;
  String? userId;

  ChatPage({Key? key, required this.groupId, required this.groupName,
    required this.userName, required this.userImage,
    this.userId,}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  NotificationManager? notificationManager;
  List<String>? members = List.empty(growable: true);
  List<String>? tokens = List.empty(growable: true);

  @override
  void initState() {
    getGroupChatsAndAdmin();
    super.initState();
    getGroupMembersAndTokens();
    notificationManager = NotificationManager();
  }

  getGroupChatsAndAdmin() {
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

  Widget buildChatbox() {
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
                  Flexible(child: Padding(padding: const EdgeInsets.symmetric(horizontal: Sizes.dimen_10),
                      child: TextField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: messageController,
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Type here...',
                            hintStyle: TextStyle(color: AppColors.white)),
                        style: const TextStyle(
                            color: Colors.white),
                      ))),
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
                  buildChatMessages(),
                  buildChatbox(),
                ])
            )
        )
        )
    );
  }

  void getGroupMembersAndTokens() async {

    print("GroupId ${widget.groupId}");
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      List<String>? local = List.from(snapshot.get('members'));
      for (var mem in local) {
        members?.add(mem.split("_")[0]);
      }

      members?.forEach((member) async {
        await FirebaseFirestore.instance.collection("users").doc(member).get().then((snapshot) async {
          if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey("token")) {
            String token = snapshot.data()!["token"];
            tokens?.add(snapshot.data()!["token"]);
          }
        });
      });
    });
  }

  Widget buildChatMessages() {
    return Flexible(
        child: StreamBuilder(
          stream: chats,
          builder: (context, AsyncSnapshot snapshot) {
            return snapshot.hasData ? ListView.builder(
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
            ) : Container();
          },
        )
    );
  }

  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: widget.userName, body: action,);

    tokens?.forEach((token){
      notificationManager?.sendNotification(token, model);
    });
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
      sendNotification(messageController.text);
      messageController.clear();
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      messageController.clear();
    }
  }
}