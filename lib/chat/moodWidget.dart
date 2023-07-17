import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/chat/constants.dart';
import 'package:sharedstudent1/chat/moodModel.dart';
import '../misc/global.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/ssbadge.dart';
import 'chatWidgets.dart';

class MoodWidget extends StatefulWidget {

  MoodModel moodModel;
  BuildContext context;

  MoodWidget({super.key, required this.moodModel, required this.context,});

  @override
  State<MoodWidget> createState() => MoodWidgetState();
}

class MoodWidgetState extends State<MoodWidget> {
  Size? size;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String? myUserId = "";

  late Widget likeBadgeView;
  late Widget angryBadgeView;
  late Widget loveItBadgeView;
  late Widget sadBadgeView;

  @override
  void initState() {
    super.initState();

    size = MediaQuery.of(widget.context).size;
    myUserId = _auth.currentUser?.uid;
  }

  buildActionViews(){
    likeBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.like.length.toString(),
        child: IconButton(
            icon: Icon(widget.moodModel.like.contains(myUserId) ? Icons.thumb_up :
            Icons.thumb_up_alt_outlined), color: Colors.green,
            onPressed: () {
              handleLikes();
        }));

    loveItBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.loveIt.length.toString(),
        child: IconButton(
            icon: Icon(widget.moodModel.loveIt.contains(myUserId) ? Icons.favorite_outlined :
            Icons.favorite_border), color: Colors.red,
            onPressed: () {
              handleLoves();
        }));

    sadBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.sad.length.toString(),
        child: IconButton(
            icon: Icon(widget.moodModel.sad.contains(myUserId) ? Icons.sentiment_dissatisfied_outlined :
            Icons.sentiment_dissatisfied), color: Colors.indigo,
        onPressed: () {
          handleSadness();
        }));

    angryBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.angry.length.toString(),
        child: IconButton(
            icon: Icon(widget.moodModel.angry.contains(myUserId) ? Icons.sentiment_very_dissatisfied_outlined :
            Icons.sentiment_very_dissatisfied), color: Colors.purple,
          onPressed: () {
            handleAnger();
        }));
  }

  handleLikes() {
    if (widget.moodModel.like.contains(myUserId)) {
      widget.moodModel.like.remove(myUserId);
    }
    else {
      widget.moodModel.like.add(myUserId!);
    }

    fireStore.collection(FirestoreConstants.pathMoodCollection).doc(widget.moodModel.moodId)
        .update({FirestoreConstants.like: widget.moodModel.like,});

    setState(() {
      widget.moodModel.like;
    });
  }

  handleLoves() {
    if (widget.moodModel.loveIt.contains(myUserId)) {
      widget.moodModel.loveIt.remove(myUserId);
    }
    else {
      widget.moodModel.loveIt.add(myUserId!);
    }

    fireStore.collection(FirestoreConstants.pathMoodCollection).doc(widget.moodModel.moodId)
        .update({FirestoreConstants.loveIt: widget.moodModel.loveIt,});

    setState(() {
      widget.moodModel.loveIt;
    });
  }

  handleSadness() {
    if (widget.moodModel.sad.contains(myUserId)) {
      widget.moodModel.sad.remove(myUserId);
    }
    else {
      widget.moodModel.sad.add(myUserId!);
    }

    fireStore.collection(FirestoreConstants.pathMoodCollection).doc(widget.moodModel.moodId)
        .update({FirestoreConstants.sad: widget.moodModel.sad,});
    setState(() {
      widget.moodModel.sad;
    });
  }

  handleAnger() {
    if (widget.moodModel.angry.contains(myUserId)) {
      widget.moodModel.angry.remove(myUserId);
    }
    else {
      widget.moodModel.angry.add(myUserId!);
    }

    fireStore.collection(FirestoreConstants.pathMoodCollection).doc(widget.moodModel.moodId)
        .update({FirestoreConstants.angry: widget.moodModel.angry,});

    setState(() {
      widget.moodModel.angry;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildActionViews();

    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                widget.moodModel.type == PostType.video.name ? Container(
                    margin: const EdgeInsets.only(
                        right: Sizes.dimen_10, top: Sizes.dimen_10),
                    child: AspectRatio(aspectRatio: 4/3,
                      child: Container()
                      // BetterPlayer.network(widget.moodModel.content,
                      //   betterPlayerConfiguration: const BetterPlayerConfiguration(
                      //     aspectRatio: 4/3,
                      //   ),
                      // ),
                    )
                ) :
                widget.moodModel.type == PostType.image.name ?
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Image border
                  child: SizedBox.fromSize(
                      size: Size(500.0, size == null ? 400 : size!.height * 0.5),
                      // Image radius
                      child: Image.network(widget.moodModel.content, fit: BoxFit.cover)
                  ),
                ) :
                messageBubble(chatContent: widget.moodModel.content,
                  color: AppColors.spaceLight, textColor: AppColors.white,
                  margin: const EdgeInsets.only(right: Sizes.dimen_10), width: 500.0),
                const SizedBox(height: 12.0,),
                Row(children: [ likeBadgeView, loveItBadgeView,
                  angryBadgeView, sadBadgeView
                ],),
                const SizedBox(height: 15.0,),
                Row(children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) =>
                            UsersProfilePage(userId: widget.moodModel.idFrom,
                              userName: widget.moodModel.displayName,
                              userImage: widget.moodModel.photoUrl,)));
                      },
                      child: widget.moodModel.photoUrl == null ? Image.asset("assets/images/wolf.webp", width: 50, height: 50,) : CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(widget.moodModel.photoUrl!,),
                      )
                  ),
                  Padding(padding: const EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.moodModel.displayName, style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            DateFormat("dd MMM, yyyy - hh:mm a").format(
                                widget.moodModel.timestamp.toDate()).toString(),
                            style: const TextStyle(color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          )
                        ]
                    ),
                  ),
                ]
                ),
              ],
            )
        ),
      ),
    );
  }
}