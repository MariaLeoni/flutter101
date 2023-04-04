import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../home_screen/home.dart';
import '../home_screen/picturesHomescreen.dart';
import '../home_screen/videosHomescreen.dart';
import '../log_in/login_screen.dart';
import '../misc/global.dart';
import '../misc/userModel.dart';
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          CircleAvatar(
              backgroundColor: Colors.white54,
              minRadius: 90.0,
              child: CircleAvatar(
                  radius:80.0,
                  backgroundImage: NetworkImage(
                    widget.userImage!,
                  )
              )
          ),
          const SizedBox(height: 24),
          OutlinedButton(
              onPressed: () async {
                handleFollowerPost();
              },
              child: Text(amFollowingUser ? "Unfollow $myName" : "Follow $myName",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
          ),
          const SizedBox(height: 24),
          NumbersWidget(followers: widget.followers, following: widget.following, userName: myName ?? "",),
          const SizedBox(height:24),
          const Center(child: Text("User Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
          const SizedBox(height:8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                  onPressed: () async {
                    handlePostView(PostType.video);
                  },
                  child: Text(videosCount > 1 ? "$videosCount Videos" : "$videosCount Video",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
              ),
              buildDivider(),
              OutlinedButton(
                  onPressed: () async {
                    handlePostView(PostType.image);
                  },
                  child: Text(picturesCount > 1 ? "$picturesCount Pictures" : "$picturesCount Picture",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  handlePostView(PostType type){
    UserWithNameAndId user = UserWithNameAndId(userId: widget.userId!, userName: myName!);
    if (type == PostType.image){
      Navigator.push(context, MaterialPageRoute(builder: (_) => PictureHomeScreen.forUser(user: user,)));
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (_) => VideoHomeScreen.forUser(user: user,)));
    }
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
  }
  AddFollowToActivityFeed() {
    bool isNotPostOwner = _auth.currentUser!.uid != widget.userId;
    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection('Activity Feed').doc(widget.userId)
          .collection('FeedItems').doc(ActivityId).set({
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
        "postOwnerId": widget.userId,
        "postOwnerImage": null,
        "postOwnername": null,
        "downloads": null,
        "Read Status": false,
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
