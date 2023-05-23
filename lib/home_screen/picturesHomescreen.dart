import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/notification/server.dart';
import 'package:sharedstudent1/postUploader.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:uuid/uuid.dart';
import '../Activity Feed/activityFeedScreen.dart';
import '../chat/socialHomeScreen.dart';
import '../misc/userModel.dart';
import '../notification/notification.dart';
import '../profile/profile_screen.dart';
import '../search.dart';
import '../owner_details/owner_details.dart';
import '../search_post/users_specific_posts.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/ssbadge.dart';

final themeMode = ValueNotifier(2);

class PictureHomeScreen extends StatefulWidget {
  String category = "";
  UserWithNameAndId? user;

  PictureHomeScreen.forCategory({super.key, required this.category});
  PictureHomeScreen.forUser({super.key, required this.user, });

  @override
  State<PictureHomeScreen> createState() => PictureHomeScreenState();
}

class PictureHomeScreenState extends State<PictureHomeScreen> {
  String changeTitle = "Grid View";
  int activityCount  = 0;
  int? total;
  String? name;
  String? image;
  int? viewCount = 0;
  String postId = const Uuid().v4();
  Map<String, List<String>?> interests = {};
  NotificationManager? notificationManager;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String currentToken;
  String userIdx = FirebaseAuth.instance.currentUser!.uid;
  Size? size;
  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);

  @override
  void initState() {
    super.initState();
     getAllProducts();
     getDataFromDatabase();
     notificationManager = NotificationManager();
     notificationManager?.initServer();

  //  sendNotification();

      _messaging.getToken().then((value) {
        print(value);
        if (mounted) {
          setState(() {
            currentToken = value!;
          });
        }
        firestore.collection('pushtokens')
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
          viewCount: viewCount, postId: postId, likes: likes, viewers: viewers,
          description: description,
        )));
  }


   getAllProducts() async {
     final collection = firestore.collection("Activity Feed")
         .doc(userIdx).collection('FeedItems');
     final query = collection.where("Read Status", isEqualTo: false);
     final countQuery = query.count();
     final AggregateQuerySnapshot snapshot = await countQuery.get();
     debugPrint("Count: ${snapshot.count}");
     activityCount = snapshot.count;
   }
  getDataFromDatabase() async {
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
                      updateViewAndNavigate(viewCount, postId, viewers, img, userImg,
                          name, date, docId, userId, downloads, likes, description);
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
                  Row(children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                                userId:docId,
                                userName:name,
                                userImage: userImg,
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
              ],
            )
        ),
      ),
    );
  }

  void updateViewAndNavigate(int viewCount, String postId, List<String>? viewers, String img,
      String userImg, String name, DateTime date, String docId, String userId,
      int downloads, List<String>? likes, String description) {
    total = viewCount + 1;

    if (viewers != null && !viewers.contains(userIdx)){
      viewers.add(userIdx);
    }

    firestore.collection('wallpaper').doc(postId)
        .update({'viewers': viewers,'viewcount': total,
    });

    goToDetails(img, userImg, name, date, docId, userId, downloads, viewCount,
        postId, likes,viewers, description);
  }

  void updateInterests(Map<String, List<String>?> interests) {
    setState(() {
      this.interests = interests;
    });
  }

  @override
  Widget build(BuildContext context) {
    var activityBadgeView = SSBadge(top: 0, right: 2,
        value: activityCount.toString(),
        child: IconButton(
            icon: const Icon(Icons.doorbell_outlined), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFeed()));
        }));

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
                width: 100,
                margin: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "1",
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        PostUploader(postType: PostType.image,)));
                  },
                  child:
                  ImageIcon(
                    AssetImage('assets/images/ttent.png'),
                    size: 600,
                    color: Colors.red,
                  ),
                 // const Icon(Icons.camera_enhance),
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
              title: Text("${widget.category}"),
              centerTitle: true,
              leading: IconButton(
                                onPressed: () {
                                  if (widget.user == null){
                                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                        VideoHomeScreen.forCategory(category: widget.category,),),);
                                  }
                                  else{
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => VideoHomeScreen.forUser(user: widget.user,)));
                                  }
                                },
                                icon: const Icon(Icons.play_circle_outlined),
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                      userId:userIdx,
                      userName:name,
                      userImage: image,
                    )));
                  },
                  icon: const Icon(Icons.person),
                ),

                activityBadgeView,
                IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SocialHomeScreen()));
                  },
                  icon: const Icon(Icons.message_sharp),
                )
              ]
          ),
          body: StreamBuilder(
              stream: widget.user != null ? firestore.collection('wallpaper').
              where("id", isEqualTo: widget.user!.userId).snapshots() :

              widget.category == "random" ? firestore.collection('wallpaper')
                  .orderBy('createdAt', descending: true).snapshots() :

              firestore.collection('wallpaper').
              where("category", arrayContains: widget.category).snapshots(),

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
                        child: Text("Sorry, there are no Posts for selection",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),)
                    );
                  }
                }
                return const Center(
                  child: Text('Something went wrong', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
                  ),
                );
              }
          ),
        )
    );
  }
}

