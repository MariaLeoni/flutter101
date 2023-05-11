 import 'package:flutter/material.dart';
import '../chat/chatWidgets.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final String senderImage;
  final bool sentByMe;

  const MessageTile(
      {Key? key,
        required this.message,
        required this.sender,
        required this.senderImage,
        required this.sentByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return
      Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
        const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
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
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child:

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap:(){
                },
                child: CircleAvatar(radius:15,
                  backgroundImage: NetworkImage(
                    widget.senderImage!,),
                )
            ),
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,

            ),
            Text(widget.message,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16, color: Colors.white))


          ],
        ),



    ));

    // )//        Container   (
    //     //           clipBehavior: Clip.hardEdge,
    //     //           decoration: BoxDecoration(
    //     // borderRadius: BorderRadius.circular(Sizes.dimen_20),
    //     // ),
    //     // child: Image.network(
    //     // widget.senderImage,
    //     // width: Sizes.dimen_40,
    //     // height: Sizes.dimen_40,
    //     // fit: BoxFit.cover,
    //     // loadingBuilder: (BuildContext ctx, Widget child,
    //     // ImageChunkEvent? loadingProgress) {
    //     // if (loadingProgress == null) return child;
    //     // return Center(
    //     // child: CircularProgressIndicator(
    //     // color: AppColors.burgundy,
    //     // value: loadingProgress.expectedTotalBytes !=
    //     // null &&
    //     // loadingProgress.expectedTotalBytes !=
    //     // null
    //     // ? loadingProgress.cumulativeBytesLoaded /
    //     // loadingProgress.expectedTotalBytes!
    //     //     : null,
    //     // ),
    //     // );
    //     // },
    //     // errorBuilder: (context, object, stackTrace) {
    //     // return const Icon(
    //     // Icons.account_circle,
    //     // size: 35,
    //     // color: AppColors.greyColor,
    //     // );
    //     // },
    //     // )
      // GestureDetector(
      //     onTap:(){
      //     },
      //     child: CircleAvatar(radius:15,
      //       backgroundImage: NetworkImage(
      //         widget.senderImage!,),
      //     )
      // ),



  }
}