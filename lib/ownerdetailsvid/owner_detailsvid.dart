import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../home_screen/home.dart';
import '../widgets/button_square.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';

class  VideoDetailsScreen extends StatefulWidget {
  String? likeruserId;
  String? vid;
  String? userImg;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;
  String? postId;
  String? description;

  List<String>? likes = List.empty(growable: true);
  List<String>? followers = List.empty(growable: true);

  VideoDetailsScreen({super.key, this.likeruserId,this.vid, this.userImg, this.name, this.date,
    this.docId, this.userId, this.downloads, this.postId, this.likes, this. description,
  });

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();

}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  int? total;
  int likesCount = 0;
  int followersCount = 0;
  String? postId;
  String? likerUserId;
  String? followUserId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  handleFollowerPost() {
    if (widget.followers!= null && widget.followers!.contains(followUserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers!.remove(followUserId);
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers!.add(followUserId!);
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
    if (widget.likes != null && widget.likes!.contains(likerUserId)) {
      Fluttertoast.showToast(msg: "You unliked this image!");
      widget.likes!.remove(likerUserId);
    }
    else {
      Fluttertoast.showToast(msg: "You liked this image!");
      widget.likes!.add(likerUserId!);
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
    likerUserId = _auth.currentUser?.uid;
    likesCount = (widget.likes?.length ?? 0);

    var likeText = Text(likesCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));

    followUserId = _auth.currentUser?.uid;
    followersCount = (widget.followers?.length ?? 0);

    var followerText = Text(followersCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors:[Colors.black, Colors.black],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2,0.9]
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
                GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
                        userId:widget.docId,
                        userName:widget.name,
                      )));
                    },
                    child: CircleAvatar(radius:35,
                      backgroundImage: NetworkImage(widget.userImg!,),
                    )
                ),
                const SizedBox(height:30.0,),
                Text('Uploaded by: ${widget.name!}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0,),
                Text(DateFormat("dd MMM, yyyy - hh:mm a"). format(widget.date!).toString(),
                    style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold,)
                ),
                const SizedBox(height:10.0),
                SizedBox(width: 250, child: Text(widget.description!,
                  maxLines: 3, overflow: TextOverflow.fade,
                  textAlign: TextAlign.start, style: const TextStyle(color: Colors.white54,
                      fontWeight: FontWeight.bold),
                )
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try{
                          var imageId = await ImageDownloader.downloadImage(widget.vid!);
                          if(imageId == null) {
                            return;
                          }
                          Fluttertoast.showToast(msg: "Image saved to Gallery");
                          total= widget.downloads! +1;

                          FirebaseFirestore.instance.collection('wallpaper2')
                              .doc(widget.postId).update({'downloads': total,
                          }).then((value) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
                          });
                        } on PlatformException catch (error)
                        {
                          print(error);
                        }

                      },
                      child: const Icon(Icons.download, color:Colors.white,),
                    ),
                    Text("${widget.downloads}",
                      style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        Share.share(widget.vid!);
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Comment(postId: widget.postId, userId: widget.userId,)));
                      },
                      icon: const Icon(Icons.insert_comment_sharp, color: Colors.white),
                    ),
                    IconButton(onPressed: () async{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                    }, icon: const Icon(Icons.home, color: Colors.white)),
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
                  ],
                ),
                const SizedBox(height: 50.0,),
                FirebaseAuth.instance.currentUser!.uid == widget.docId  ?
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                    child: ButtonSquare(text:"Delete",
                        colors1: Colors.black,
                        colors2: Colors.black,

                        press: () async {
                          FirebaseFirestore.instance.collection('wallpaper')
                              .doc(widget.postId).delete().then((value) {
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
