import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Activity Feed/activityFeedScreen.dart';
import '../Search.dart';
import '../chat/socialHomeScreen.dart';
import '../misc/userModel.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/ssbadge.dart';
import 'home.dart';
import 'post.dart';
import '../misc/global.dart';
import '../owner_details/owner_detailsvid.dart';
import '../postUploader.dart';
import '../vidlib/ReusableVideoListController.dart';
import '../vidlib/ReusableVideoListWidget.dart';
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
  ReusableVideoListController videoListController = ReusableVideoListController();
  int lastMilli = DateTime.now().millisecondsSinceEpoch;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Size? size;
  String? name;
  String? image;
  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);


  @override
  void initState() {
    super.initState();
    getAllProducts();
    getDataFromDatabase();
  }

  void videoSelected(VideoListData videoListData){
    Post post = videoListData.post;
    goToDetails(post.source, post.userImage, post.userName, post.createdAt, post.id, post.email,
        post.downloads, post.description, post.likes, post.postId);
  }

  void goToDetails(String vid, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String description,
      List<String>? likes, String postId) {

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
        backgroundColor: Colors.transparent,
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
            title: const Text("Videos"),
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

                    VideoListData videoListData = VideoListData(post);
                    return  ReusableVideoListWidget(videoListData: videoListData,
                      videoListController: videoListController,
                      canBuildVideo: checkCanBuildVideo,videoSelected: (VideoListData videoListData){
                        videoSelected(videoListData);
                      },
                    );
                  },
                );
              }
              else{
                return const Center(
                    child: Text("Sorry, there are no Posts for selection",
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
      ),
    );
  }
}
