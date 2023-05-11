import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/ownerdetailsvid/owner_detailsvid.dart';
import 'package:sharedstudent1/search_userpost/searchView.dart';
import '../following/follows.dart';
import '../home_screen/home.dart';
import '../home_screen/post.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../owner_details/owner_details.dart';
import '../profile/profile_screen.dart';
import'package:fluttertoast/fluttertoast.dart';
import '../vidlib/ReusableVideoListController.dart';
import '../vidlib/ReusableVideoListWidget.dart';
import '../vidlib/VideoListData.dart';
import '../widgets/ssbadge.dart';


class  UsersSpecificPostsScreen extends StatefulWidget {
  String? userId;
  String? userName;
  String? docId;
 PostType? postType;
  List<String>? followers = List.empty(growable: true);

  UsersSpecificPostsScreen({super.key,
    this.userId,
    this.userName,
   this.followers,
    this.docId,
    this.postType,
  });

  @override
  State<UsersSpecificPostsScreen> createState() => UsersSpecificPostsScreenState();
}

class UsersSpecificPostsScreenState extends State<UsersSpecificPostsScreen> {
  String? myUserId;
  String? myImage;
  String? myName;
  String? name;
  String? image;
  String? tokens;
  NotificationManager? notificationManager;
  int followersCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool amFollowingUser = false;
  ReusableVideoListController videoListController = ReusableVideoListController();
  void getUserToken() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.docId).get().then((snapshot) async { if (snapshot.exists) {
      setState(() {
        tokens = snapshot.data()!["devicetoken"];
      });
    }
    });
  }

  void sendNotification() {
    NotificationModel model = NotificationModel(title: name,
        body: "Followed you", //dataBody: "should be post url",
        //dataTitle: "Should be post description"
        );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }

  addFollowToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.userId)
          .collection('FeedItems').doc(widget.userId).set({
        "type": "follow",
        "name": name,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": image,
        "postId": null,
        "Image": null,
        "timestamp": DateTime.now(),
        "commentData":  null,
        "description": null,
        "likes": null,
        "postOwnerId": null,
        "postOwnerImage": null,
        "postOwnername": null,
        "downloads": null,
        "Read Status": false,
      });
    }
  }

  removeFollow() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed')
          .doc(widget.userId)
          .collection('FeedItems')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  handleFollowerPost() {
    if (widget.followers!= null && widget.followers!.contains(myUserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers?.remove(myUserId);
      removeFollow();
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers?.add(myUserId!);
      addFollowToActivityFeed();
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'followers': widget.followers!,
    }).then((value) {
      setState(() {
        followersCount = widget.followers?.length ?? 0;
        amFollowingUser = widget.followers == null ? false : widget.followers!.contains(myUserId);
      });
    });
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
  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(widget.userId)
        .get().then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      widget.followers = List.from(snapshot.get('followers'));

      setState(() {
        followersCount = widget.followers?.length ?? 0;
        amFollowingUser = widget.followers == null ? false : widget.followers!.contains(myUserId);
      });
    });
  }

  void loadMyDetails() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(myUserId).get().then((snapshot) async { if (snapshot.exists) {
      setState(() {
        name = snapshot.data()!["name"];
        image = snapshot.data()!["userImage"];
      });
    }
    });
  }

  @override
  void initState() {
    super.initState();

    myUserId = _auth.currentUser?.uid;

    loadMyDetails();
    getUserToken();
    readUserInfo();

    notificationManager = NotificationManager();
    notificationManager?.initServer();
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
                    Navigator.push(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
                      img: img, userImg: userImg, name: name, date: date, docId: docId,
                      userId: userId, downloads: downloads, postId: postId, likes: likes,
                    description: description,
                    )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Image border
                    child: SizedBox.fromSize(
                        size: const Size(500.0, 400.0), // Image radius
                        child: Image.network(img, fit: BoxFit.cover)
                    ),
                  ),
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            userImg,
                          ),
                        ),
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
                                DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    followersCount = (widget.followers?.length ?? 0);
    amFollowingUser = widget.followers == null ? false : widget.followers!.contains(myUserId);

    var followersBadgeView = SSBadge(top: 0, right: 2,
        value: followersCount.toString(),
        child: IconButton(
            icon: amFollowingUser ? const Icon(Icons.person_remove_alt_1_outlined, color: Colors.red) :
            const Icon(Icons.person_add_alt_outlined, color: Colors.white), onPressed: () {
          handleFollowerPost();
        }));


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
            title: Text(widget.userName!,),
            centerTitle: true,
          //  leading:
        ),
         body:
         widget.postType == PostType.image?
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('wallpaper').where("id", isEqualTo: widget.userId)
              .orderBy('createdAt',descending: true).snapshots(),

          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty)
              {
                return ListView.builder(itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {

                    Post post = Post.getPost(snapshot, index, PostType.image);
                    return listViewWidget(post.id, post.source, post.userImage,
                        post.userName, post.createdAt, post.email,
                        post.downloads, post.postId, post.likes, post.description);
                  },
                );
              }
              else{
                return const Center(child: Text("This user has  no Posts.",
                      style: TextStyle(fontSize: 20, color: Colors.white))
                );
              }
            }
            return const Center(child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ):
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('wallpaper2').where("id", isEqualTo: widget.userId)
              .orderBy('createdAt',descending: true).snapshots(),

          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
                if(snapshot.data!.docs.isNotEmpty) {
                  return PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
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
                return const Center(child: Text("This user has  no Posts.",
                    style: TextStyle(fontSize: 20, color: Colors.white))
                );
              }
            }
            return const Center(child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            );
          },
        )
      ),
    );
  }
}

