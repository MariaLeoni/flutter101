import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  late Widget likeBadgeView;
  late Widget angryBadgeView;
  late Widget loveItBadgeView;
  late Widget sadBadgeView;

  @override
  void initState() {
    super.initState();

    size = MediaQuery.of(widget.context).size;

    buildActionViews();
  }

  buildActionViews(){
    likeBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.like.length.toString(),
        child: IconButton(
            icon: const Icon(Icons.thumb_up_alt_outlined), color: Colors.green,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => handleLikes()));
        }));

    loveItBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.loveIt.length.toString(),
        child: IconButton(
            icon: const Icon(Icons.favorite_border), color: Colors.red,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => handleLoves()));
        }));

    sadBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.sad.length.toString(),
        child: IconButton(
            icon: const Icon(Icons.sentiment_dissatisfied), color: Colors.indigo,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => handleSadness()));
        }));

    angryBadgeView = SSBadge(top: 0, right: 2,
        value: widget.moodModel.angry.length.toString(),
        child: IconButton(
            icon: const Icon(Icons.sentiment_very_dissatisfied), color: Colors.purple,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => handleAnger()));
        }));
  }

  handleLikes() async {

  }

  handleLoves() async {

  }

  handleSadness() async {

  }

  handleAnger() async {

  }

  @override
  Widget build(BuildContext context) {
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
                      child: BetterPlayer.network(widget.moodModel.content,
                        betterPlayerConfiguration: const BetterPlayerConfiguration(
                          aspectRatio: 4/3,
                        ),
                      ),
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
                Row(children: [ likeBadgeView!, loveItBadgeView!,
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