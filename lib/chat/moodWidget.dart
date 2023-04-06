import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/chat/moodModel.dart';
import '../misc/global.dart';
import '../search_post/users_specifics_page.dart';
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

  @override
  void initState() {
    super.initState();

    size = MediaQuery.of(widget.context).size;
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
                    child:
                    AspectRatio(aspectRatio: 4/3,
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
                      size: Size(
                          500.0, size == null ? 400 : size!.height * 0.75),
                      // Image radius
                      child: Image.network(widget.moodModel.content, fit: BoxFit.cover)
                  ),
                ) : messageBubble(chatContent: widget.moodModel.content,
                  color: AppColors.spaceLight,
                  textColor: AppColors.white,
                  margin: const EdgeInsets.only(right: Sizes.dimen_10),),
                const SizedBox(height: 12.0,),
                Row(children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) =>
                            UsersProfilePage(userId: widget.moodModel.idFrom,
                              userName: widget.moodModel.displayName,
                              userImage: widget.moodModel.photoUrl,)));
                      },
                      child: widget.moodModel.photoUrl == null ? Image.asset("assets/images/wolf.webp") : CircleAvatar(
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