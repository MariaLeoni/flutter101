import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Activity Feed/activityFeedScreen.dart';
import '../Search.dart';
import '../chat/socialHomeScreen.dart';
import '../misc/userModel.dart';
import '../search_post/users_specifics_page.dart';
import '../vidlib/chewieVideoWidget.dart';
import '../widgets/ssbadge.dart';
import 'home.dart';
import 'post.dart';
import '../misc/global.dart';
import '../owner_details/owner_detailsvid.dart';
import '../uploader/postUploader.dart';
import '../vidlib/VideoListData.dart';


class VideoHomeScreen extends StatefulWidget {

  String category = "";

  UserWithNameAndId? user;
  String? userId;
  VideoHomeScreen.forUser({super.key, required this.user});
  VideoHomeScreen.forCategory({super.key, required this.category});

  @override
  State<VideoHomeScreen> createState() => VideoHomeScreenState();
}

class VideoHomeScreenState extends State<VideoHomeScreen> {
  bool checkView = false;
  int activityCount  = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController(initialPage: 0, keepPage: true);

  Size? size;
  String? name;
  String? image;

  Widget listViewWidget1 (String docId, String vid, String userImg, String name,
      DateTime date, String userId, int downloads, String postId,
      List<String>? likes, String description) {

    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        color: Colors.black,
        child: Column(
              children: [
                GestureDetector(
                  onTap:() {
                    Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
                      vid: vid, userImg: userImg, name: name, date: date, docId: docId,
                      userId: userId, downloads: downloads, postId: postId, likes: likes,
                      description: description,
                    )));
                  },
                  child: SizedBox.fromSize(
                      size: Size(500.0, size == null ? 400 : size!.height * 0.65), // Image border
                      child:  ChewieVideoWidget(autoPlayAndFullscreen: false, url: vid, file: null,)
                  ),
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
                        GestureDetector(
                            onTap:() {
                              Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
                                vid: vid, userImg: userImg, name: name, date: date, docId: docId,
                                userId: userId, downloads: downloads, postId: postId, likes: likes,
                                description: description,
                              )));
                            },
                            child:
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                userImg,
                              ),
                            )),
                        const SizedBox(width: 10.0,),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                DateFormat("dd MMM, yyyy - hh:mm a").format(date).toString(),
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

  @override
  void initState() {
    super.initState();
    getAllProducts();
    getDataFromDatabase();
  }

  void videoSelected(VideoListData videoListData){
    Post post = videoListData.post;
    goToDetails(post.source, post.userImage, post.userName, post.createdAt, post.id, post.email,
        post.downloads, post.description, post.likes, post.postId, post.downloaders);
  }

  void goToDetails(String vid, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String description,
      List<String>? likes, String postId, List<String>? downloaders) {

    Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
      vid:vid, userImg: userImg, name: name, date: date,
      docId: docId, userId: userId, downloads: downloads, description: description,
      likes: likes, postId: postId,
    )));
  }

  getAllProducts() async {
    final collection = firestore.collection("Activity Feed")
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('FeedItems');
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

  @override
  Widget build(BuildContext context) {
    var activityBadgeView = SSBadge(top: 0, right: 2,
        value: activityCount.toString(),
        child: IconButton(
            icon: const Icon(Icons.doorbell_outlined), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFeed()));
        }));
    size = MediaQuery.of(context).size;

    return Scaffold(
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PostUploader(postType: PostType.video)));
                },
                child:
                const ImageIcon(AssetImage('assets/images/ttent.png'),
                  size: 600, color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        appBar: AppBar(
            flexibleSpace:Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
            title: Text(widget.category),
            centerTitle: true,
            leading:
            IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(),),);
              },
              icon: const Icon(Icons.home),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Search(postType: PostType.video,),),);
                },
                icon: const Icon(Icons.person_search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                    userId:FirebaseAuth.instance.currentUser!.uid,
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
              ),
            ]
        ),
        body: StreamBuilder(
          stream: widget.user != null ? firestore.collection('wallpaper2')
              .where("id", isEqualTo: widget.user!.userId).snapshots() :

          widget.category == "random" ? firestore.collection('wallpaper2')
              .orderBy('createdAt', descending: true).snapshots() :

          firestore.collection('wallpaper2')
              .where("category", arrayContains: widget.category).snapshots(),

          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty) {

                return PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {

                    Post post = Post.getPost(snapshot, index, PostType.video);
                    return listViewWidget1(post.id, post.source, post.userImage,
                        post.userName, post.createdAt, post.email,
                        post.downloads, post.postId, post.likes, post.description);
                  },
                );
              }
              else{
                return const Center(
                    child: Text("Be the first to post in this collection",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                          color: Colors.white),)
                );
              }
            }
            return const Center(
              child: Text('Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
              ),
            );
          },
        ),
    );
  }
}
