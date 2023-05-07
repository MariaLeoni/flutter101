import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sharedstudent1/search_post/users_specifics_page.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/home.dart';
import '../misc/alertbox.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../widgets/button_square.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';


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
  int? viewCount;
  String? postId;
  bool? isRead;
  List<String>? likes = List.empty(growable: true);
  List<String>? viewers = List.empty(growable: true);
  List<String>? followers = List.empty(growable: true);

  OwnerDetails({super.key, this.likeruserId, this.img, this.userImg, this.name, this.date,
    this.docId, this.userId, this.downloads, this.viewCount, this.postId, this.likes,
    this.viewers, this.description, this.isRead
  });

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> with TickerProviderStateMixin {

  int? total;
  int likesCount = 0;
  int followersCount = 0;
  String? postId;
  int? feedCount;
  String? likerUserId;
  String? followUserId;
  String? name;
  String? userImage;
  String?image;
  String? tokens;
  NotificationManager? notificationManager;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String activityId = const Uuid().v4();

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
  void getDataFromDatabase3() async {
    await FirebaseFirestore.instance.collection("Activity Feed")
        .doc(widget.docId).collection('Feed Count').doc(widget.docId)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        feedCount = snapshot.data()!["Feed Count"];
      });
    }
    });
  }

  void sendNotification() {
    NotificationModel model = NotificationModel(title: name,
      body: "Liked your post", dataBody: widget.img,
      // dataTitle: "Should be post description"
    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }

  void getDataFromDatabase2() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.docId)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        tokens = snapshot.data()!["devicetoken"];
      });
    }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
    getDataFromDatabase2();
    notificationManager = NotificationManager();
    notificationManager?.initServer();
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
        "Image": widget.userImg,
        "timestamp": DateTime.now(),
        "commentData": null,
        "downloads": widget.downloads,
        "description": widget.description,
        "likes": widget.likes,
        "postOwnerId": widget.docId,
        "postOwnerImage": widget.img,
        "postOwnername": widget.name,
        "likes": widget.likes,
        "Read Status": false,

      }).then((value) {
        FirebaseFirestore.instance.collection('Activity Feed')
            .doc(widget.docId).collection('Feed Count').doc(widget.docId).update(
            {'Feed Count': feedCount! + 1,
            });
      }
      );
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.docId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed')
          .doc(widget.docId)
          .collection('FeedItems')
          .doc(widget.postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  handleLikePost(){
    if (widget.likes != null && widget.likes!.contains(likerUserId)) {
      Fluttertoast.showToast(msg: "You unliked this image!");
      widget.likes!.remove(likerUserId);
      removeLikeFromActivityFeed();
    }
    else {
      Fluttertoast.showToast(msg: "You liked this image!");
      widget.likes!.add(likerUserId!);
      addLikeToActivityFeed();
      sendNotification();
    }


    FirebaseFirestore.instance.collection('wallpaper').doc(widget.postId)
        .update({'likes': widget.likes!,
    }).then((value){
      setState(() {
        likesCount = (widget.likes?.length ?? 0);
      });
    });
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
      title: Text("Description"),
      content: Text(widget.description!),
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
  @override
  Widget build(BuildContext context) {
    likerUserId = _auth.currentUser?.uid;
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
                // const Text('Post Information', style: TextStyle(
                //   fontSize: 20.0, color: Colors.white54, fontWeight: FontWeight.bold,),
                // ) ,
                // const SizedBox(height: 30.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
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
                              backgroundImage: NetworkImage(
                                widget.userImg!,),
                            )
                        ),
                        Padding(padding: const EdgeInsets.all(10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text(widget.name!,
                                    style: const TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold),),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    DateFormat("dd MMM, yyyy - hh:mm a").format(widget.date!).toString(),
                                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height:10.0),
                                  GestureDetector(
                                    onTap: (){
                                      showAlertDialog(context);
                                    },
                                    child: SizedBox(width: 250, child: Text(widget.description!,
                                      maxLines: 3, overflow: TextOverflow.fade,
                                      textAlign: TextAlign.start, style: const TextStyle(color: Colors.white54,
                                          fontWeight: FontWeight.bold),
                                    )
                                    )
                                  )
                                  // SizedBox(width: 250, child: Text(widget.description!,
                                  //   maxLines: 3, overflow: TextOverflow.fade,
                                  //   textAlign: TextAlign.start, style: const TextStyle(color: Colors.white54,
                                  //       fontWeight: FontWeight.bold),
                                  // )
                                  // )
                                ]
                            )
                        )
                      ]
                  ),
                ),
        Padding(padding: const EdgeInsets.all(10.0),
          child:
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try{
                          var imageId = await ImageDownloader.downloadImage(widget.img!);
                          if(imageId == null) {
                            return;
                          }
                          Fluttertoast.showToast(msg: "Image saved to Gallery");
                          total= widget.downloads! +1;

                          FirebaseFirestore.instance.collection('wallpaper')
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
                    Padding(padding: const EdgeInsets.only(left: 8.0, ),
                    child:
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (_) =>
                            Comment(postId: widget.postId, userId: widget.docId,
                              image: widget.img, likes: widget.likes,
                              description: widget.description,
                              downloads: widget.downloads, postOwnerImg: widget.userImg,
                              postOwnername: widget.name,)));
                      },
                      icon: const Icon(Icons.insert_comment_sharp, color: Colors.white),
                    ),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 8.0, ),
                      child:
                      IconButton(
                      onPressed: () async {
                        Share.share(widget.img!);
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 8.0, ),
                      child:
                      IconButton(onPressed: () async{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                    }, icon: const Icon(Icons.home, color: Colors.white))),
                    Padding(padding: const EdgeInsets.only(left: 8.0, ),
                        child:
                        GestureDetector(
                          onTap: () {
                            handleLikePost();
                          },
                          child: const Icon (
                            Icons.thumb_up_sharp,
                            color: Colors.white,
                          ),
                        )),
                    likeText,
                  ],
                ),
        ),
                const SizedBox(height: 50.0,),
                FirebaseAuth.instance.currentUser!.uid == widget.docId
                    ?
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                    child: ButtonSquare(text:"Delete",
                        colors1: Colors.black, colors2: Colors.black,
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
