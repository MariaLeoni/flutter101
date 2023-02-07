import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/video/videopost.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../Search.dart';
import '../message/sendmessage.dart';
import '../ownerdetailsvid/owner_detailsvid.dart';
import '../profile/profile_screen.dart';
import'package:video_player/video_player.dart';
import '../search_userpost/searchView.dart';
import '../uploaderVideo.dart';


class VideoHomeScreen extends StatefulWidget {

  @override
  State<VideoHomeScreen> createState() => VideoHomeScreenState();
}

class VideoHomeScreenState extends State<VideoHomeScreen> {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;
  bool checkView = false;

  File? imageFile;
  File? videoFile;
  String? videoUrl;
  String? myImage;
  String? myName;
  String? vid;


  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }

  @override
  void initState() {
    super.initState();
    readUserInfo();
  }

  Widget listViewWidget (String docId, String vid, String userImg, String name,
      DateTime date, String userId, int downloads, String description,
      List<String>? likes , String postId  ) {

    _videoPlayerController1 = VideoPlayerController.network(vid);
    _chewieController = ChewieController(videoPlayerController: _videoPlayerController1!,
      aspectRatio:5/6, autoPlay: true, looping: false,
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
                heroTag: "1",
                backgroundColor: Colors.deepPurple,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VideoUploader()));
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
            title: const Text("Video Posts"),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Icon(
                  Icons.login_outlined
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Search(),),);
                },
                icon: const Icon(Icons.person_search),
              ),
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
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

          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting )
            {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active)
            {
              if(snapshot.data!.docs.isNotEmpty)
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