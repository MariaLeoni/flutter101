import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharedstudent1/profile/profile_screen.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/home.dart';
import '../misc/global.dart';
import '../misc/userModel.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import '../search_userpost/searchView.dart';
import '../widgets/widgets.dart';
import 'numbers_widget.dart';

class UsersProfilePage extends StatefulWidget {
  String? userId;
  String? userName;
  String? docId;
  String?userImage;
  List<String>? followers = List.empty(growable: true);
  List<String>? following = List.empty(growable: true);

  UsersProfilePage({super.key,
    this.userId,
    this.userName,
    this.followers,
    this.docId,
    this.userImage,
    this.following,
  });

  @override
  UsersProfilePageState createState() => UsersProfilePageState();
}

class UsersProfilePageState extends State<UsersProfilePage> {
  String? myImage;
  String? myName;
  String? myUserId;
  String? name;
  String? image;
  int followersCount = 0;
  int followingCount = 0;
  int videosCount = 0;
  int picturesCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool amFollowingUser = false;
  String ActivityId = const Uuid().v4();
  String? tokens;
  NotificationManager? notificationManager;

  @override
  void initState() {
    super.initState();

    myUserId = _auth.currentUser?.uid;

    readUserInfo();
    readUserInfo2();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace:Container(
          color: Colors.black,
          ),
          title: Text(widget.userName!,),
          centerTitle: true,
          //leading:
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(),),);
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
              },
              icon: const Icon(Icons.home),
            ),
          ]
      ),
      body:Container(
    color:Colors.black, child:
      ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          CircleAvatar(
              backgroundColor: Colors.transparent,
              minRadius: 90.0,
              child: CircleAvatar(
                  radius:80.0,
                  backgroundImage: NetworkImage(
                    widget.userImage!,
                  )
              )
          ),
          const SizedBox(height: 24),
          FirebaseAuth.instance.currentUser!.uid == widget.userId
              ?
          
          OutlinedButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(
                )));
              },
              child: const Text("Settings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 , ),
              ),
          ):

          OutlinedButton(
              onPressed: () async {
                handleFollowerPost();
              },
              child: Text(amFollowingUser ? "Unfollow $myName" : "Follow $myName",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, ),
              ),

                  ),
          const SizedBox(height: 24),
          NumbersWidget(followers: widget.followers, following: widget.following, userName: myName ?? "",),
          const SizedBox(height:24),
          const Center(child: Text("User Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color:Colors.white),),),
          const SizedBox(height:8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        UsersSpecificPostsScreen(userId: widget.userId, userName: myName!, postType: PostType.video,)));
                  },
                  child: Text(videosCount > 1 ? "$videosCount Videos" : "$videosCount Video",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,  ),
                  ),
           ),
              buildDivider(),
              OutlinedButton(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        UsersSpecificPostsScreen(userId: widget.userId, userName: myName!, postType: PostType.image,)));
                    },
                  child: Text(picturesCount > 1 ?"$picturesCount Pictures" : "$picturesCount Picture",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,  ),
                  ),
              ),
            ],
          )
        ],
      ),
    ));
  }


  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(widget.userId).get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      widget.followers = List.from(snapshot.get('followers'));
      widget.following = List.from(snapshot.get('following'));

      setState(() {
        followersCount = widget.followers?.length ?? 0;
        followingCount = widget.following?.length ?? 0;
        amFollowingUser = widget.followers == null ? false : widget.followers!.contains(myUserId);
      });
    });
  }
  void readUserInfo2() async {
    FirebaseFirestore.instance.collection('users').doc(myUserId).get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      name = snapshot.get('name');
      image = snapshot.get('userImage');


    });
  }
  void getPosts() async {
    videosCount = await getVideoPosts();
    picturesCount = await getPicturePost();

    setState(() {
      videosCount;
      picturesCount;
    });
  }

  handleFollowerPost() {
    if (widget.followers!= null && widget.followers!.contains(myUserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers!.remove(myUserId);
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers!.add(myUserId!);
    }

    setState(() {
      followersCount = widget.followers?.length ?? 0;
      amFollowingUser = widget.followers == null ? false : widget.followers!.contains(myUserId);
    });

    FirebaseFirestore.instance.collection('users').doc(widget.userId)
        .update({'followers': widget.followers!,});
    sendNotification("Started following you");
    addFollowToActivityFeed();
  }
  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: name,
      body: action, dataBody: image,
    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }

  addFollowToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.userId)
          .collection('FeedItems').doc(ActivityId).set({
        "type": "follow",
        "name": name,
        "userId": _auth.currentUser!.uid,
        "userProfileImage": image,
        "Activity Id": ActivityId,
        "postId": "",
        "Image": image,
        "timestamp": DateTime.now(),
        "commentData":  "",
        "description": "",
        "likes": "",
        "postOwnerId": "",
        "postOwnerImage": "",
        "postOwnername": "",
        "downloads": "",
        "Read Status": "",
        "PostType": "image",
      });
    }
  }

  Future<int> getPicturePost() async {
    final collection = FirebaseFirestore.instance.collection('wallpaper').where("id", isEqualTo: widget.userId);
    final countQuery = collection.count();
    final AggregateQuerySnapshot snapshot = await countQuery.get();
    return snapshot.count;
  }

  Future<int> getVideoPosts() async {
    final collection = FirebaseFirestore.instance.collection('wallpaper2').where("id", isEqualTo: widget.userId);
    final countQuery = collection.count();
    final AggregateQuerySnapshot snapshot = await countQuery.get();
    return snapshot.count;
  }
}
