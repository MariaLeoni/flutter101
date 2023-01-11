import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_downloader/image_downloader.dart';
import '../home_screen/homescreen.dart';
import '../widgets/button_square.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:video_player/video_player.dart';
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

  List<String>? likes = List.empty(growable: true);
  List<String>? followers = List.empty(growable: true);
  //String?id;


  OwnerDetails({super.key, this.likeruserId,this.vid, this.userImg, this.name, this.date,
    this.docId, this.userId, this.downloads, this.postId, this.likes,
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
  VideoPlayerController? _videoPlayerController1;
  VideoPlayerController? _videoPlayerController2;
  ChewieController? _chewieController;
  ChewieController? _chewieController2;
  _OwnerDetailsState({
    String? postId,
    String? userId,
  });



  handlefollowerPost() {

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


    FirebaseFirestore.instance.collection('wallpaper').doc(widget.postId)
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

    _videoPlayerController1 = VideoPlayerController.network(widget.vid!);
    _videoPlayerController2 = VideoPlayerController.network(
        'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4');

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      aspectRatio: 4 / 3,
      autoPlay: true,
      looping: false,
    );

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
                Container(
                  child: Column(
                    children: [
                       Chewie( controller: _chewieController!)
                    ],
                  ),

                ),
                const SizedBox(height: 30.0,),

                const Text(
                  'Owner Information',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ) ,
                const SizedBox(height: 30.0,),

                GestureDetector(
                    onTap:(){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
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


                const SizedBox(height:70.0,),

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
                      onPressed: (){
                        handlefollowerPost();
                      },
                      icon: const Icon(Icons.follow_the_signs),
                    ),
                    followerText,
                  ],
                ),
                const SizedBox(height: 50.0,),

                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
                    child: ButtonSquare(
                        text: "Download",
                        colors1: Colors.green,
                        colors2: Colors.lightGreen,

                        press: () async
                        {
                          try{
                            var imageId = await ImageDownloader.downloadImage(widget.userImg!);
                            if(imageId == null)
                            {
                              return;
                            }
                            Fluttertoast.showToast(msg: "Image saved to Gallery");
                            total= widget.downloads! +1;

                            FirebaseFirestore.instance.collection('wallpaper')
                                .doc(widget.postId).update({'downloads': total,
                            }).then((value)
                            {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
                            });
                          } on PlatformException catch (error)
                          {
                            print(error);
                          }
                        }
                    )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                  child: ButtonSquare(
                      text:"Delete",
                      colors1: Colors.green,
                      colors2: Colors.lightGreen,

                      press: () async
                      {
                        FirebaseFirestore.instance.collection('wallpaper')
                            .doc(widget.docId).delete()
                            .then((value)
                        {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                        });
                      }

                  ),
                ),

                Container(),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                  child: ButtonSquare(
                      text:"Go Back",
                      colors1: Colors.green,
                      colors2: Colors.lightGreen,

                      press: () async
                      {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                      }

                  ),

                ),
                Padding(padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                  child: ButtonSquare(
                      text:"Comment",
                      colors1: Colors.green,
                      colors2: Colors.lightGreen,
                      press: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Comment(postId: widget.postId, userId: widget.userId,)));
                      }
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
