import 'package:flutter/material.dart';
import '../search_post/users_specifics_page.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final String senderImage;
  final String senderId;
  final bool sentByMe;

  const MessageTile(
      {Key? key,
        required this.message,
        required this.sender,
        required this.senderImage,
        required this.senderId,
        required this.sentByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4,
          left: widget.sentByMe ? 0 : 10,
          right: widget.sentByMe ? 10 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(margin: widget.sentByMe
            ? const EdgeInsets.only(left: 70)
            : const EdgeInsets.only(right: 70),
        padding: const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(borderRadius: widget.sentByMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: widget.sentByMe ? Theme.of(context).primaryColor : Colors.grey[700]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                    userId:widget.senderId,
                    userName:widget.sender,
                    userImage:  widget.senderImage,
                  )));
                },
                child: Row(children: [
                  CircleAvatar(radius:15, backgroundImage: NetworkImage(widget.senderImage,),),
                  const SizedBox(width: 8,),
                  Text(widget.sender,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                  ),
                ],),
            ),
            const SizedBox(height: 8,),
            Text(widget.message, textAlign: TextAlign.start, style: const TextStyle(fontSize: 16, color: Colors.white))
          ],
        ),
    ));
  }
}