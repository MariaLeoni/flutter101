import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/video/videoposts.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../Campuses1.dart';
import '../profile/myprofile.dart';
import '../search.dart';
import '../uploader.dart';
import '../owner_details/owner_details.dart';
import'package:uuid/uuid.dart';
import '../search_post/users_specific_posts.dart';

final themeMode = ValueNotifier(2);

class HomeScreen extends StatefulWidget {
  String? userId;
  String? name;
  String? userImg;

  HomeScreen({super.key, this.userId, this.name, this.userImg,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String changeTitle="Grid View";
  bool checkView =false;

  File? imageFile;
  File? videoFile;
  String? videoUrl;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? userId;
  String postId = const Uuid().v4();

  void readUserInfo() async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      userId = FirebaseAuth.instance.currentUser!.uid;
    });

    FirebaseFirestore.instance.collection('category').get().then(
            (QuerySnapshot snapshot) => snapshot.docs.forEach((f) => {
              print("Found ${(List.from(f.get("subCategory"))).toString()}")
    }));
  }

  @override
  void initState() {
    super.initState();
    readUserInfo();

    // Timer.run(() {
    //   FancyAlertDialog.showFancyAlertDialog(
    //     context, 'Info Fancy Alert Dialog Box',
    //     'This is a info alert dialog box. This plugin is used to help you easily create fancy dialog',
    //     icon: const Icon(
    //       Icons.clear,
    //       color: Colors.black,
    //     ),
    //     labelPositiveButton: 'OKAY',
    //     onTapPositiveButton: () {
    //       Navigator.of(context).pop(false);
    //       print('tap positive button');
    //     },
    //     labelNegativeButton: 'Cancel',
    //     onTapNegativeButton: () {
    //       Navigator.of(context, rootNavigator: true).pop();
    //       print('tap negative button');
    //     },
    //   );
    // });
  }

  void goToDetails(String img, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String postId, List<String>? likes, String description) {

    Navigator.push(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
      img: img, userImg: userImg, name: name, date: date, docId: docId,
      userId: userId, downloads: downloads, postId: postId, likes: likes,
      description: description,
    )));
  }

  Widget listViewWidget (String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, String postId,
      List<String>? likes, String description) {

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
                GestureDetector(
                  onTap:() {
                    goToDetails(img, userImg, name, date, docId, userId,
                        downloads, postId, likes, description);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Image border
                    child: SizedBox.fromSize(
                        size: const Size(500.0, 400.0), // Image radius
                        child: Image.network(img, fit: BoxFit.cover)
                    ),
                  )
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
                        GestureDetector(
                            onTap:(){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
                                userId:docId,
                                userName:name,
                              )));
                            },
                            child: CircleAvatar(
                              radius:35,
                              backgroundImage: NetworkImage(userImg,),
                            )
                        ),
                        Padding(padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text(name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
                                  style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                                )
                              ]
                          ),
                        ),
                      ]
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  Widget gridViewWidget (String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, String postId,
      List<String>? likes, String description) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(2.0),
        crossAxisSpacing: 0,
        crossAxisCount: 1,
        children: [
          Container(
            decoration: const BoxDecoration(),
            padding: const EdgeInsets.all(2.0),
            child: GestureDetector(
                onTap:() {
                  goToDetails(img, userImg, name, date, docId, userId, downloads, postId, likes, description);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Image border
                  child: SizedBox.fromSize(
                      size: const Size.fromRadius(48), // Image radius
                      child: Image.network(img, fit: BoxFit.fill, width: 200, height: 300,)
                  ),
                )
            ),
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
                heroTag: "1",
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      Uploader()));
                },
                child: const Icon(Icons.camera_enhance),
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
                  stops: [0.2],
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
              onDoubleTap: () {
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Icon(Icons.login_outlined),
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
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Campuses()));

                  Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile(
                    userId: widget.userId, userName: myName, followers: const [],
                  ),),);
                },
                icon: const Icon(Icons.person),
              ),
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VideoHomeScreen(),),);
                },
                icon: const Icon(Icons.play_circle_outlined ),
              ),

              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Campuses1(),),);
                },
                icon: const Icon(Icons.stream_outlined),
              ),
            ]
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('wallpaper')
              .orderBy('createdAt',descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty){
                if(checkView == true)
                {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      Post post = Post.getPost(snapshot, index);

                      return listViewWidget(post.id, post.image, post.userImage,
                          post.userName, post.createdAt, post.email,
                          post.downloads, post.postId, post.likes,post.description);
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
                      itemBuilder: (BuildContext context, int index) {
                        Post post = Post.getPost(snapshot, index);

                        return gridViewWidget(post.id, post.image, post.userImage,
                            post.userName, post.createdAt, post.email,
                            post.downloads, post.postId, post.likes, post.description);
                      }
                  );
                }
              }
              else {
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


