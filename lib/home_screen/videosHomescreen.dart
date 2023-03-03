import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../Search.dart';
import '../chat/chatListScreen.dart';
import 'home.dart';
import 'post.dart';
import '../misc/global.dart';
import '../ownerdetailsvid/owner_detailsvid.dart';
import '../profile/profile_screen.dart';
import '../postUploader.dart';
import '../vidlib/ReusableVideoListController.dart';
import '../vidlib/ReusableVideoListWidget.dart';
import '../vidlib/VideoListData.dart';


class VideoHomeScreen extends StatefulWidget {

  String category = "";

  VideoHomeScreen({super.key, required this.category});

  @override
  State<VideoHomeScreen> createState() => VideoHomeScreenState();
}

class VideoHomeScreenState extends State<VideoHomeScreen> {
  bool checkView = false;

  ReusableVideoListController videoListController = ReusableVideoListController();
  int lastMilli = DateTime.now().millisecondsSinceEpoch;

  int _currentPage = 0;
  bool _isOnPageTurning = false;

  Size? size;
  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);

  void _scrollListener() {
    if (_isOnPageTurning && _pageController.page == _pageController.page!.roundToDouble){
      setState(() {
        _currentPage = _pageController.page!.toInt();
        _isOnPageTurning = false;
      });
    } else if (!_isOnPageTurning && _currentPage.toDouble() != _pageController.page) {
      if ((_currentPage.toDouble() - _pageController.page!).abs()>0.7){
        setState(() {
          _isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _pageController.addListener(_scrollListener);
  }

  void videoSelected(VideoListData videoListData){
    Post post = videoListData.post;
    goToDetails(post.source, post.userImage, post.userName, post.createdAt, post.id, post.email,
        post.downloads, post.description, post.likes, post.postId);
  }

  void goToDetails(String vid, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, String description,
      List<String>? likes, String postId) {

    Navigator.push(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
      vid:vid, userImg: userImg, name: name, date: date,
      docId: docId, userId: userId, downloads: downloads, description: description,
      likes: const [], postId: postId,
    )));
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
                backgroundColor: Colors.deepPurple,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PostUploader(postType: PostType.video)));
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
                  colors: [Colors.black, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
            title: const Text("Videos"),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Search(postType: PostType.video,),),);
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
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ChatListScreen(),),);
                },
                icon: const Icon(Icons.chat_bubble),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
                },
                icon: const Icon(Icons.home),
              ),
            ]
        ),
        body: StreamBuilder(stream: widget.category == "random" ? FirebaseFirestore.instance
              .collection('wallpaper2').orderBy('createdAt', descending: true).snapshots() :

          FirebaseFirestore.instance.collection('wallpaper2')
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
                    return ReusableVideoListWidget(videoListData: videoListData,
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
                    child: Text("Sorry, there are no Posts for selection", style: TextStyle(fontSize: 20),)
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
