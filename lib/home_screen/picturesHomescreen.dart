import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/Activity%20Feed/feed.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/notification/server.dart';
import 'package:sharedstudent1/postUploader.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../notification/notification.dart';
import '../profile/profile_screen.dart';
import '../search.dart';
import '../owner_details/owner_details.dart';
import '../search_post/users_specific_posts.dart';

final themeMode = ValueNotifier(2);

class PictureHomeScreen extends StatefulWidget {
  String category = "";

  PictureHomeScreen({super.key, required this.category});

  @override
  State<PictureHomeScreen> createState() => PictureHomeScreenState();
}

class PictureHomeScreenState extends State<PictureHomeScreen> {

  Map<String, List<String>?> interests = {};
  NotificationManager? notificationManager;

  Size? size;
  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);

  @override
  void initState() {
    super.initState();

    notificationManager = NotificationManager();
    notificationManager?.initServer();

    //sendNotification();

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

  void sendNotification() {
    NotificationModel model = NotificationModel(title: "Hello from Jonas",
        body: "Jonas has just liked your post", dataBody: "should be post url",
        dataTitle: "Should be post description");
    String token = "fRUDbKNKRz6gQ7v2MWGAA5:APA91bELAlAPokiqOjgItWg3S0zMKGNdzf7SZJSdrGWKjBOz2seG7FlHPRUcD7KN8RNYiAo8uiatHDnM8RZi_yQKSB4wyRlUVIA0h3f46UpzhLCORW0a1A20mtEU2-PPH6AWQcqKKZQ3";
    notificationManager?.sendNotification(token, model);
  }

  void goToDetails(String img, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String postId,
      List<String>? likes, String description) {

    Navigator.push(context, MaterialPageRoute(builder: (_) =>
        OwnerDetails(img: img, userImg: userImg, name: name,
          date: date, docId: docId, userId: userId, downloads: downloads,
          postId: postId, likes: likes, description: description,
        )));
  }


  Widget listViewWidget(String docId, String img, String userImg, String name,
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
                    onTap: () {
                      goToDetails(img, userImg, name, date,
                          docId, userId, downloads, postId, likes,
                          description);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Image border
                      child: SizedBox.fromSize(
                          size: Size(500.0, size == null ? 400 : size!.height * 0.75), // Image radius
                          child: Image.network(img, fit: BoxFit.cover)
                      ),
                    )
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (_) =>
                                  UsersSpecificPostsScreen(
                                    userId: docId, userName: name,
                                  )));
                            },
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(userImg,),
                            )
                        ),
                        Padding(padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  DateFormat("dd MMM, yyyy - hh:mm a").format(
                                      date).toString(),
                                  style: const TextStyle(color: Colors.white54,
                                      fontWeight: FontWeight.bold),
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

  void updateInterests(Map<String, List<String>?> interests) {
    setState(() {
      this.interests = interests;
    });
  }

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;

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
                        PostUploader(postType: PostType.image,)));
                  },
                  child: const Icon(Icons.camera_enhance),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
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
              title: const Text("Photos", style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Icon(Icons.login_outlined),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Search(postType: PostType.image,),),);
                  },
                  icon: const Icon(Icons.person_search),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(),),);
                  },
                  icon: const Icon(Icons.person),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => VideoHomeScreen(category: widget.category,),),);
                  },
                  icon: const Icon(Icons.play_circle_outlined),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFeed()));
                  },
                  icon: const Icon(Icons.doorbell_outlined),
                ),
              ]
          ),
          body: StreamBuilder(
              stream: widget.category == "random" ? FirebaseFirestore.instance
                  .collection('wallpaper').orderBy('createdAt', descending: true).snapshots() :

              FirebaseFirestore.instance.collection('wallpaper')
                  .where("category", arrayContains: widget.category).snapshots(),

              builder: (BuildContext context,
                  AsyncSnapshot <QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                else if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    return PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      controller: _pageController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        Post post = Post.getPost(snapshot, index, PostType.image);

                        return listViewWidget(post.id, post.source, post.userImage,
                            post.userName, post.createdAt, post.email,
                            post.downloads, post.postId, post.likes, post.description);
                      },
                    );
                  }
                  else {
                    return const Center(
                        child: Text("Sorry, there are no Posts for selection", style: TextStyle(fontSize: 20),)
                    );
                  }
                }
                return const Center(
                  child: Text('Something went wrong', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                );
              }
          ),
        )
    );
  }
}