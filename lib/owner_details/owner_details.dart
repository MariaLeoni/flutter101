import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sharedstudent1/owner_details/userListScreen.dart';
import 'package:sharedstudent1/search_post/users_specifics_page.dart';
import 'package:sharedstudent1/widgets/ssbadge.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/home.dart';
import '../misc/global.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sharedstudent1/Comments/Comment.dart';
import '../widgets/button_square.dart';


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
  List<String>? downloaders = List.empty(growable: true);

  OwnerDetails({super.key, this.likeruserId, this.img, this.userImg, this.name,
    this.date, this.docId, this.userId, this.downloads, this.viewCount,
    this.postId, this.likes, this.viewers, this.description, this.isRead,
    this.downloaders});

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> with TickerProviderStateMixin {
  int? total = 0;
  int likesCount = 0;
  int followersCount = 0;
  String? postId;
  int? feedCount;
  String? userId;
  String? name;
  String? userImage;
  String?image;
  String? tokens;
  String? token;
  NotificationManager? notificationManager;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String activityId = const Uuid().v4();

  void getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection("users").doc(userId)
        .get().then((snapshot) async { if (snapshot.exists) {
      setState(() {
        name = snapshot.data()!["name"];
        image = snapshot.data()!["userImage"];
        token = snapshot.data()!["token"];
      });
    }
    });
  }

  void getDataFromDatabase3() async {
    await FirebaseFirestore.instance.collection("Activity Feed")
        .doc(widget.docId).collection('Feed Count').doc(widget.docId).get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        feedCount = snapshot.data()!["Feed Count"];
      });
    }
    });
  }

  void sendNotification(String action) {
    bool isNotPostOwner = token != tokens;
    if (isNotPostOwner) {
      NotificationModel model = NotificationModel(title: name,
        body: "Liked your post", dataBody: widget.img,
        // dataTitle: "Should be post description"
      );
      String? token = tokens;
      notificationManager?.sendNotification(token!, model);
    }
  }

  void getDataFromDatabase2() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.docId)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        tokens = snapshot.data()!["token"];
      });
    }
    });
  }

  @override
  void initState() {
    super.initState();

    userId = _auth.currentUser!.uid;

    print("Downloaders ${widget.downloaders}");

    getDataFromDatabase();
    getDataFromDatabase2();
    notificationManager = NotificationManager();
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = userId != widget.docId;
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
        "Image": widget.img,
        "timestamp": DateTime.now(),
        "commentData": "",
        "downloads": widget.downloads,
        "description": widget.description,
        "likes": widget.likes,
        "postOwnerId": widget.docId,
        "postOwnerImage": widget.img,
        "postOwnername": widget.name,
        "Read Status": false,
        "PostType" : "image",
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = userId != widget.docId;
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
    if (widget.likes != null && widget.likes!.contains(userId)) {
      Fluttertoast.showToast(msg: "You unliked this image!");
      widget.likes!.remove(userId);
      removeLikeFromActivityFeed();
    }
    else {
      Fluttertoast.showToast(msg: "You liked this image!");
      widget.likes!.add(userId!);
      addLikeToActivityFeed();
      sendNotification("Liked your post");
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
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        print('tap negative button');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Container(color:Colors.black,child:Text("Description", style: TextStyle(color:Colors.red.shade900))),
      content: Container(color:Colors.black,
          child:Text(widget.description!,
              style:const TextStyle(color:Colors.white, fontWeight: FontWeight.bold))),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    likesCount = (widget.likes?.length ?? 0);
    setState(() {
      total = widget.downloads ?? 0;
    });

    var likeText = SSBadge(top:0, right:2, value: likesCount.toString(),
      child: GestureDetector(
        onTap:(){},
        onDoubleTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen(
            users: widget.likes,
          )));
        },
        child: IconButton(onPressed: () {
          handleLikePost();
        },
            icon: const Icon(Icons.thumb_up_sharp, color: Colors.white, size: 25,)),
      ),
    );

    var downloadText = SSBadge(top:0, right:2, value: total.toString(),
      child: GestureDetector(
          onTap:(){},
          onDoubleTap: (){
            if (widget.downloaders!.isNotEmpty){
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen(
                users: widget.downloaders,
              )));
            }
          },
          child:  IconButton(onPressed: () async {
            try{
              Dio dio = Dio();
              var fileNameDecoded = getFileName(widget.img!, PostType.image);
              var dir = await getTemporaryDirectory();
              final String savePath = "${dir.path}/$fileNameDecoded.jpg";

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Downloading image...")));

              await dio.download(widget.img!, savePath,
                  onReceiveProgress: (received, total) {
                    if (total != -1) {
                      print("Downloaded ${(received / total * 100).toStringAsFixed(0)}%");
                    }
                  });
              await ImageGallerySaver.saveFile(savePath);

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Image saved to Image Gallery")));

              handleDownloadCompleted();
            } on PlatformException catch (error) {
              print(error);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Sorry, am unknown error occurred.")));
            }
          },
            icon: const Icon (
              Icons.download,
              color: Colors.white,
              size: 25,
            ),
          )),
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2],
            ),
          ),
        ),
      ),
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
                Image.network(
                  widget.img!,
                  width: MediaQuery.of(context).size.width,
                ),
                const SizedBox(height: 7.0,),
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
                      downloadText,
                      Padding(padding: const EdgeInsets.only(left: 8.0, ),
                        child:
                        IconButton(
                          onPressed: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (_) =>

                                Comment(postId: widget.postId, userId: widget.docId,
                                  image: widget.img, likes: widget.likes,
                                  description: widget.description,
                                  downloads: widget.downloads, postOwnerImg: widget.userImg,
                                  postOwnername: widget.name, postType: PostType.image.name,)));
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
                        child: likeText,
                      ),
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
                            Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const HomeScreen()));
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

  void handleDownloadCompleted() {
    total = widget.downloads! + 1;
    setState(() {
      total;
    });
    List downloaders = List.from(widget.downloaders!);
    downloaders.add(userId);

    FirebaseFirestore.instance.collection('wallpaper')
        .doc(widget.postId)
        .update({'downloads': total, 'downloaders': downloaders
    });
  }
}
