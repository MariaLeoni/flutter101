import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/Activity%20Feed/feed.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/notification/server.dart';
import 'package:sharedstudent1/postUploader.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:uuid/uuid.dart';
import '../misc/alertbox.dart';
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


  String changeTitle = "Grid View";
  bool checkView = false;


  int ActivityCount = 0;
  String? videoUrl;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? userId;
  int? total;
  String postId = const Uuid().v4();
  Map<String, List<String>?> interests = {};
  NotificationManager? notificationManager;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late String currentToken;
  String userIdx = FirebaseAuth.instance.currentUser!.uid;
  Size? size;
  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);

  @override
  void initState() {
    super.initState();

    notificationManager = NotificationManager();
    notificationManager?.initServer();

  //  sendNotification();

      _messaging.getToken().then((value) {
        print(value);
        if (mounted)
          setState(() {
            currentToken = value!;
          });
        FirebaseFirestore.instance
            .collection('pushtokens')
            .doc(userIdx)
            .set({'token': value!, 'createdAt': DateTime.now()});
      });
    // Timer.run(() {
    //   FancyAlertDialog.showFancyAlertDialog(
    //     context, 'Maria',
    //     'just liked your post',
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
    String token = "fWrxOXwIS-i5hWV3hBRAuy:APA91bGho335472C4RUCFbzCIPzGzIS2Gb0j519yuSuGCxTiqeau4_PsG9pB0coGwEQyjhmEGzBUhLsL4eN4LrAcaBtG3uhKgeeS7uFleU7FUUzAg5a9F5ac-2cX9P7sTz6UMZ2831VQ";
    notificationManager?.sendNotification(token, model);
  }

  void goToDetails(String img, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, int viewCount, String postId,
      List<String>? likes, List<String>? viewers,String description) {

    Navigator.push(context, MaterialPageRoute(builder: (_) =>
        OwnerDetails(img: img, userImg: userImg, name: name,
          date: date, docId: docId, userId: userId, downloads: downloads,
          viewCount: viewCount,
          postId: postId, likes: likes,viewers: viewers, description: description,
        )));
  }
// viewcounts(){
//     total = viewcount! + 1;
//     FirebaseFirestore.instance.collection('wallpaper').doc(postId).update({'viewcount': viewcount, });
// }
  Future<void> getAllProducts() async {
    CollectionReference productsRef =
    FirebaseFirestore.instance.collection('Activity Feed');
    final snapshot = await productsRef.doc(userIdx).collection('Feed Items').get();
    List<Map<String, dynamic>> Activitynotifs =
    snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      ActivityCount = (Activitynotifs.length ?? 0);
    });
  }

  Widget listViewWidget(String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, int viewCount, String postId,
      List<String>? likes, List<String>? viewers, String description) {

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
                      total = viewCount +1;
                      FirebaseFirestore.instance.collection('wallpaper'). doc(postId).update({
                        'viewcount': total,
                      });
                        if (viewers != null && viewers!.contains(userIdx)){
                          goToDetails(img, userImg, name, date,
                              docId, userId, downloads,viewCount, postId, likes,viewers,
                              description);
                        }
                        else {
                          viewers!.add(userIdx);
                        }
                        FirebaseFirestore.instance.collection('wallpaper').doc(postId)
                            .update({'viewers': viewers,
                        }).then((value){
                          goToDetails(img, userImg, name, date,
                              docId, userId, downloads,viewCount, postId, likes,viewers,
                              description);
                        });


                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Image border
                      child: SizedBox.fromSize(
                          size: Size(500.0, size == null ? 400 : size!.height * 0.75), // Image radius
                          child: Image.network(img, fit: BoxFit.cover)
                      ),
                    )
                ),
                 const SizedBox(height: 12.0,),
                // Padding(
                //   padding: const EdgeInsets.only(
                //       left: 8.0, right: 8.0, bottom: 8.0),
                 // child:
                  Row(
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
                //)
              ],
            )
        ),
      ),
    );
  }


  Widget gridViewWidget(String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, int viewCount, String postId,
      List<String>? likes, List<String>? viewers, String description) {

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
                onTap: () {
                  total = viewCount +1;
                  FirebaseFirestore.instance.collection('wallpaper'). doc(postId).update({
                    'viewcount': total,
                  });
                  if (viewers != null && viewers!.contains(userIdx)){
                    goToDetails(img, userImg, name, date,
                        docId, userId, downloads,viewCount, postId, likes,viewers,
                        description);
                  }
                  else {
                    viewers!.add(userIdx);
                  }
                  FirebaseFirestore.instance.collection('wallpaper').doc(postId)
                      .update({'viewers': viewers,
                  }).then((value){
                    goToDetails(img, userImg, name, date,
                        docId, userId, downloads,viewCount, postId, likes,viewers,
                        description);
                  });


                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Image border
                  child: SizedBox.fromSize(
                      size: const Size.fromRadius(48), // Image radius
                      child: Image.network(
                        img, fit: BoxFit.fill, width: 200, height: 300,)
                  ),
                )
            ),
          ),
        ]
    );
  }
  

  void updateInterests(Map<String, List<String>?> interests) {
    setState(() {
      this.interests = interests;
    });
  }

  @override
  Widget build(BuildContext context) {
    var ActivityText = Text(ActivityCount.toString(),
        style: const TextStyle(fontSize: 20.0,
            color: Colors.white, fontWeight: FontWeight.bold));
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
                ActivityText,
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
                            post.downloads, post.viewCount, post.postId, post.likes, post.viewers, post.description);
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

