import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sharedstudent1/notification/server.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/home.dart';
import '../notification/notification.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/button_square.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:video_downloader/video_downloader.dart';

import '../widgets/ssbadge.dart';
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
  String activityId = const Uuid().v4();
  String? tokens;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String? image;
  NotificationManager? notificationManager;
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
  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: name,
      body: action, dataBody: widget.vid,
      // dataTitle: "Should be post description"
    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }
  addLikeToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.docId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.docId)
          .collection('FeedItems').doc(activityId)
          .set({
        "type": "like",
        "name": name,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": image,
        "postId": widget.postId,
        "Activity Id": activityId,
        "Image": widget.vid,
        "timestamp": DateTime.now(),
        "commentData": null,
        "downloads": widget.downloads,
        "description": widget.description,
        "likes": widget.likes,
        "postOwnerId": widget.docId,
        "postOwnerImage": image,
        "postOwnername": widget.name,
        "likes": widget.likes,
        "Read Status": false,
        "PostType":"video",

      });
    }
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
    addLikeToActivityFeed();
  }
  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        print('tap negative button');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Container(color:Colors.black,child:Text("Description", style: TextStyle(color:Colors.red.shade900))),
      content: Container(color:Colors.black,child:Text(widget.description!, style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold))),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        name = snapshot.data()!["name"];
        image = snapshot.data()!["userImage"];
      });
    }
    });
  }
  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
    notificationManager = NotificationManager();
    notificationManager?.initServer();
  }
  @override
  Widget build(BuildContext context) {
    likerUserId = _auth.currentUser?.uid;
    likesCount = (widget.likes?.length ?? 0);
    var likeText = SSBadge(top:0, right:2,child:  IconButton(
      onPressed: () {
        handleLikePost();
      },
      icon: const Icon (
        Icons.thumb_up_sharp,
        color: Colors.white,
        size: 25,
      ),
    )
      , value: likesCount.toString(), );
    var downloadText = SSBadge(top:0, right:2,child:  IconButton(
      onPressed: () async {
        try{
          var imageId = await ImageDownloader.downloadImage(widget.vid!);
          if(imageId == null) {
            return;
          }
          Fluttertoast.showToast(msg: "Image saved to Gallery");
          total= widget.downloads! +1;

          FirebaseFirestore.instance.collection('wallpaper')
              .doc(widget.postId).update({'downloads': total,
          }).then((value) {
            sendNotification("downloaded your video");
          });
        } on PlatformException catch (error)
        {
          print(error);
        }
      },
      icon: const Icon (
        Icons.download,
        color: Colors.white,
        size: 25,
      ),
    )
      , value: widget.downloads.toString(), );
    // var likeText = Text(likesCount.toString(),
    //     style: const TextStyle(fontSize: 28.0,
    //         color: Colors.white, fontWeight: FontWeight.bold));

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
        Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child:Row(
                  children:[
                GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                        userId:widget.docId,
                        userName:widget.name,
                        userImage: widget.userImg,
                      )));
                    },
                    child: CircleAvatar(radius:35,
                      backgroundImage: NetworkImage(widget.userImg!,),
                    )
                ),
        Padding(padding: const EdgeInsets.all(10.0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                Text(widget.name!,
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
                GestureDetector(
                    onTap: (){
                      showAlertDialog(context);
                    },
                  child:
                SizedBox(width: 250, child: Text(widget.description!,
                  maxLines: 3, overflow: TextOverflow.fade,
                  textAlign: TextAlign.start, style: const TextStyle(color: Colors.white54,
                      fontWeight: FontWeight.bold),
                )
                ),
                )
  ],
                )
        )
                    ]
                )
        ),
          Padding(padding: const EdgeInsets.all(10.0),
            child:
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GestureDetector(
                    //   // onTap: () async {
                    //   //   try{
                    //   //     var imageId = await VideoDownloader(widget.vid!);
                    //   //     if(imageId == null) {
                    //   //       return;
                    //   //     }
                    //   //     Fluttertoast.showToast(msg: "Image saved to Gallery");
                    //   //     total= widget.downloads! +1;
                    //   //
                    //   //     FirebaseFirestore.instance.collection('wallpaper2')
                    //   //         .doc(widget.postId).update({'downloads': total,
                    //   //     }).then((value) {
                    //   //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
                    //   //     });
                    //   //   } on PlatformException catch (error)
                    //   //   {
                    //   //     print(error);
                    //   //   }
                    //   //
                    //   // },
                    //   child: const Icon(Icons.download, color:Colors.white,),
                    // ),
                    // Text("${widget.downloads}",
                    //   style: const TextStyle(
                    //     fontSize: 28.0,
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    downloadText,
                  Padding(padding: const EdgeInsets.only(left: 8.0, ),
                    child:
                    IconButton(
                      onPressed: () async {
                        Share.share(widget.vid!);
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 8.0, ),
                    child:
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Comment(postId: widget.postId, userId: widget.docId,
                          image: widget.vid, likes: widget.likes,
                          description: widget.description,
                          downloads: widget.downloads, postOwnerImg: widget.userImg,
                          postOwnername: widget.name,
                        postType: "video",)));
                      },
                      icon: const Icon(Icons.insert_comment_sharp, color: Colors.white),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 8.0, ),
                    child:
                    IconButton(onPressed: () async{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                    }, icon: const Icon(Icons.home, color: Colors.white))),
                    // GestureDetector(
                    //   onTap: () {
                    //     handleLikePost();
                    //   },
                    //   child: const Icon (
                    //     Icons.thumb_up_sharp,
                    //     size:20.0,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  Padding(padding: const EdgeInsets.only(left: 8.0, ),
                    child:
                    likeText,)
                  ],
                ),),
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
                  ])
        )


    );
  }
}
