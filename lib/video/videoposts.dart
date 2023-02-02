import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/video/videopost.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../message/sendmessage.dart';
import '../ownerdetailsvid/owner_detailsvid.dart';
import '../profile/profile_screen.dart';
import '../search_post/search_post.dart';
import'package:video_player/video_player.dart';

import 'description2.dart';


class  VideoHomeScreen extends StatefulWidget {


  @override
  State<VideoHomeScreen> createState() => VideoHomeScreenState();
}

class VideoHomeScreenState extends State<VideoHomeScreen> {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;
  String changeTitle="Grid View";
  bool checkView =false;

  File? imageFile;
  File? videoFile;
  String? videoUrl;
  String? imageUrl;
  String? myImage;
  String? myName;


  String?  vid;

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(" Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                          Icons.camera,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _getFromCamera() async
  {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        videoFile = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  void _getFromGallery() async
  {
    XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        videoFile = File(pickedFile.path);
        //  _controller = VideoPlayerController.file(videoFile!);
        //  _controller.setLooping(true);
      });
      Navigator.pop(context);
    }
  }

  void _upload_image() async
  {
    if(videoFile == null) {
      Fluttertoast.showToast(msg: 'Please select a Video');
      return;
    }
    try
    {

      final ref = FirebaseStorage.instance.ref().child('userVideos').child(DateTime.now().toString()+'mp4');
      await ref.putFile(videoFile!);
      videoUrl = await ref.getDownloadURL();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
          Description2(
            videoFile: videoUrl,
          )));
      // _videoPlayerController1 = VideoPlayerController.network(videoUrl! );
      // _videoPlayerController2 = VideoPlayerController.network(videoUrl!);
      //
      // _chewieController = ChewieController(
      //   videoPlayerController: _videoPlayerController1,
      //   aspectRatio: 1.0,
      //   autoPlay: true,
      //   looping: false,
      // );
      //
      // _chewieController2 = ChewieController(
      //   videoPlayerController: _videoPlayerController2,
      //   aspectRatio: 4 / 3,
      //   autoPlay: true,
      //   looping: false,);
      //
      // FirebaseFirestore.instance.collection('wallpaper2').doc(DateTime.now().toString()).set({
      //   'id': _auth.currentUser!.uid,
      //   'userImage': myImage,
      //   'name': myName,
      //   'email': _auth.currentUser!.email,
      //   'Video': videoUrl,
      //   'downloads': 0,
      //   'createdAt': DateTime.now(),
      // });

      Navigator.canPop(context) ? Navigator.pop(context) : null;
      videoFile = null;

    }
    catch(error)
    {
      Fluttertoast.showToast(msg: error.toString());
    }
  }


  void read_userInfo() async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot)
    {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }
  @override
  void initState() {
    super.initState();
    read_userInfo();
    _upload_image();
  }

  Widget listViewWidget (String docId, String vid, String userImg, String name,
      DateTime date, String userId, int downloads, String description,
      List<String>? likes , String postId  ) {

    _videoPlayerController1 = VideoPlayerController.network(vid);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      aspectRatio:5/8,
      autoPlay: true,
      looping: false,
    );

    return Card(
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
              GestureDetector(
                  onTap:() {
                    goToDetails(vid, userImg, name, date, docId, userId,
                        downloads, description, likes, postId);
                  },
                  child: Chewie( controller: _chewieController!)
              ),
              const SizedBox(height: 15.0,),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                    children:[
                      CircleAvatar(radius: 35,
                        backgroundImage: NetworkImage(
                          userImg,),
                      ),
                      const SizedBox(width: 10.0,),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text(name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10.0),
                            Text(DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
                              style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                            )
                          ]
                      )
                    ]
                ),
              )
            ],
          )
      ),
    );
  }

  void goToDetails(String vid, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String description,
      List<String>? likes, String postId) {

    Navigator.push(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
      vid:vid,
      userImg: userImg,
      name: name,
      date: date,
      docId: docId,
      userId: userId,
      downloads: downloads,
      description: description,
      likes: const [],
      postId: postId,
    )));
  }

  Widget gridViewWidget (String docId, String vid, String userImg, String name,
      DateTime date, String userId,int downloads, String description,
      List<String>? likes, String postId) {
    _videoPlayerController1 = VideoPlayerController.network(vid);
    _chewieController = ChewieController(videoPlayerController: _videoPlayerController1!,
      aspectRatio: 3/2, autoPlay: true, looping: false,
    );

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(2.0),
        crossAxisSpacing: 1,
        crossAxisCount: 1,
        children: [
          Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
              padding: const EdgeInsets.all(2.0),
              child: GestureDetector(
                onTap:() {
                  print("tap tap");
                  goToDetails(vid, userImg, name, date, docId, userId, downloads,
                      description , likes, postId);
                },
                child: SizedBox.fromSize(
                    size: const Size(200, 300), // Image radius
                    child: Chewie(controller: _chewieController!,)
                ),
              )
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            Container(
              margin: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                  heroTag: "2",
                  backgroundColor: Colors.purple,
                  onPressed: () {
                    _upload_image();
                  },
                  child: const Icon(Icons.cloud_upload)
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                heroTag: "1",
                backgroundColor: Colors.deepPurple,
                onPressed: () {
                  _showImageDialog();
                },
                child: const Icon(Icons.video_camera_back_outlined),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            flexibleSpace:Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                setState(() {
                  changeTitle = "List View";
                  checkView = true;
                });
              },
              onDoubleTap: ()
              {
                setState(() {
                  changeTitle= "Grid View";
                  checkView = false;
                });
              },
              child: Text(changeTitle),
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: const Icon(
                  Icons.login_outlined
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPost(),),);
                },
                icon: const Icon(Icons.person_search),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
                },
                icon: const Icon(Icons.person),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Message(),),);
                },
                icon: const Icon(Icons.message_rounded),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
                },
                icon: const Icon(Icons.home),
              ),
            ]

        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('wallpaper2')
              .orderBy('createdAt',descending: true).snapshots(),

          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting )
            {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active)
            {
              if(snapshot.data!.docs.isNotEmpty)
              {
                if(checkView == true)
                {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      Post post = Post.getPost(snapshot, index);
                      return listViewWidget( post.id, post.video, post.userImage, post.name,
                        post.createdAt, post.email, post.downloads,post.description,post.likes,post.postId,
                      );
                    },
                  );
                }
                else
                {
                  return GridView.builder(
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:2
                      ),
                      itemBuilder: (BuildContext context, int index)
                      {

                        Post post = Post.getPost(snapshot, index);
                        return gridViewWidget( post.id, post.video, post.userImage, post.name,
                          post.createdAt, post.email, post.downloads,post.description,post.likes,post.postId,
                        );
                      }
                  );
                }
              }
              else{
                return const Center(
                    child: Text("There are no Posts",
                      style: TextStyle(fontSize: 20),)
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}

