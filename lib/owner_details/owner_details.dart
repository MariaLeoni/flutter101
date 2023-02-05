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
import 'package:flutter_animated_icons/icons8.dart';
import 'package:lottie/lottie.dart';


class OwnerDetails extends StatefulWidget {
  String? likeruserId;
  String? img;
  String? userImg;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  String? description;
  int? downloads;
  String? postId;
  List<String>? likes = List.empty(growable: true);
  List<String>? followers = List.empty(growable: true);


  OwnerDetails({super.key, this.likeruserId,this.img, this.userImg, this.name, this.date,
    this.docId, this.userId, this.downloads, this.postId, this.likes, this.description
  });

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> with TickerProviderStateMixin {
  late AnimationController _favoriteController;

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

  @override
  void initState() {
    super.initState();
    _favoriteController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

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
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Image.network(
                        widget.img!,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
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
                        Padding(padding: const EdgeInsets.all(10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text(
                                    widget.name!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    DateFormat("dd MMM, yyyy - hh:mn a").format(widget.date!).toString(),
                                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height:10.0),
                                  const Text('Description',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.description!,
                                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                                  )
                                ]
                            )
                        )
                      ]
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async
                      {
                        try{
                          var imageId = await ImageDownloader.downloadImage(widget.img!);
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

                      },
                      icon: const Icon(Icons.download, color:Colors.white,),
                    ),
                    Text(
                      "${widget.downloads}",
                      style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      splashRadius: 50,
                      iconSize: 50,
                      onPressed: () {
                        if (_favoriteController.status ==
                            AnimationStatus.dismissed) {
                          _favoriteController.reset();
                          _favoriteController.animateTo(0.6);
                        } else {
                          _favoriteController.reverse();
                        }
                        handleLikePost();
                      },
                      icon: Lottie.asset(Icons8.heart_color,
                          controller: _favoriteController),
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


                FirebaseAuth.instance.currentUser!.uid == widget.docId
                    ?
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
