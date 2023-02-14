import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../home_screen/picturesHomescreen.dart';
import '../widgets/button_square.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';

class  OwnerDetails extends StatefulWidget {
  String? likeruserId;
  String? vid;
  String? userImg;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;
  //String? vid;
  String? postId;
  String? description;

  List<String>? likes = List.empty(growable: true);
  List<String>? followers = List.empty(growable: true);
  //String?id;


  OwnerDetails({super.key, this.likeruserId,this.vid, this.userImg, this.name, this.date,
    this.docId, this.userId, this.downloads, this.postId, this.likes, this. description,
  });

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();

}

class _OwnerDetailsState extends State<OwnerDetails> {

  int? total;
  int likesCount = 0;
  int followersCount = 0;
  String? postId;
  String? likeruserId;
  String? followuserId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _OwnerDetailsState({
    String? postId,
    String? userId,
  });


  handleFollowerPost() {

    if (widget.followers!= null && widget.followers!.contains(followuserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers!.remove(followuserId);
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers!.add(followuserId!);
    }

    FirebaseFirestore.instance
        .collection('wallpaper')
        .doc(widget.docId)
        .update({'followers': widget.followers!,
    }).then((value) {
      setState(() {
        followersCount = (widget.followers?.length ?? 0);
      });
    });
  }

  handleLikePost(){
    if (widget.likes != null && widget.likes!.contains(likeruserId)) {
      Fluttertoast.showToast(msg: "You unliked this image!");
      widget.likes!.remove(likeruserId);
    }
    else {
      Fluttertoast.showToast(msg: "You liked this image!");
      widget.likes!.add(likeruserId!);
    }


    FirebaseFirestore.instance.collection('wallpaper2').doc(widget.postId)
        .update({'likes': widget.likes!,
    }).then((value){
      setState(() {
        likesCount = (widget.likes?.length ?? 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    likeruserId = _auth.currentUser?.uid;
    likesCount = (widget.likes?.length ?? 0);

    var likeText = Text(likesCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));

    followuserId = _auth.currentUser?.uid;
    followersCount = (widget.followers?.length ?? 0);
    var followerText = Text(followersCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors:[Colors.purple, Colors.deepPurple.shade300],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const[0.2,0.9]
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                AspectRatio(aspectRatio: 4/3,
                  child: BetterPlayer.network(widget.vid!,
                    betterPlayerConfiguration: const BetterPlayerConfiguration(
                      aspectRatio: 4/3,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0,),
                const Text('Owner Information',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ) ,
                const SizedBox(height: 30.0,),
                GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
                        userId:widget.docId,
                        userName:widget.name,
                      )));
                    },
                    child: CircleAvatar(
                      radius:35,
                      backgroundImage: NetworkImage(
                        widget.userImg!,
                      ),
                    )
                ),
                const SizedBox(height:30.0,),
                Text('Uploaded by:${widget.name!}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0,),
                Text(
                    DateFormat("dd MMM, yyyy - hh:mm a"). format(widget.date!).toString(),
                    style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold,)
                ),
                const SizedBox(height: 50.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      size:40,
                      color: Colors.white,
                    ),
                    Text(
                      "${widget.downloads}",
                      style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleLikePost();
                      },

                      child: const Icon (
                        Icons.thumb_up_sharp,
                        size:20.0,
                        color: Colors.white,
                      ),
                    ),
                    likeText,
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Comment(postId: widget.postId, userId: widget.userId,)));
                      },
                      icon: const Icon(Icons.insert_comment_sharp, color: Colors.white),
                    ),
                    IconButton(onPressed: () async{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                    }, icon: const Icon(Icons.home, color: Colors.white))
                  ],
                ),
                const SizedBox(height: 50.0,),
                FirebaseAuth.instance.currentUser!.uid == widget.docId  ?
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                    child: ButtonSquare(
                        text:"Delete",
                        colors1: Colors.black,
                        colors2: Colors.black,

                        press: () async {
                          FirebaseFirestore.instance.collection('wallpaper')
                              .doc(widget.postId).delete()
                              .then((value)
                          {
                            Fluttertoast.showToast(msg: 'Your post has been deleted');
                            Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                          });
                        }

                    )
                ):
                Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
