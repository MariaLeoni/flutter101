import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../home_screen/home.dart';
import '../home_screen/post.dart';
import '../log_in/login_screen.dart';
import '../misc/global.dart';
import '../owner_details/owner_details.dart';
import '../search_userpost/searchView.dart';
import '../widgets/button_square.dart';
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
  });


  @override
  _UsersProfilePageState createState() => _UsersProfilePageState();
}

class _UsersProfilePageState extends State<UsersProfilePage> {
  String? myImage;
  String? myName;
  String? followuserId;
  List<String>? followingx = List.empty(growable: true);
  int followersCount = 0;
  int followingCount =0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool amFollowingUser = false;
  @override
  Widget build(BuildContext context) {
    followuserId = _auth.currentUser?.uid;
    followersCount = (widget.followers?.length ?? 0);
    amFollowingUser = widget.followers == null ? false : widget.followers!.contains(followuserId);
    var followerText = Text(followersCount.toString(),
        style: const TextStyle(fontSize: 20.0,
            color: Colors.white, fontWeight: FontWeight.bold));
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
          Center(child: amFollowingUser ?  ButtonSquare(
              text:"Following",
              colors1: Colors.black,
              colors2: Colors.black,

              press: () async {
               handleFollowerPost();
              }
          ) :
          ButtonSquare(
              text:"Follow",
              colors1: Colors.black,
              colors2: Colors.black,

              press: () async {
                handleFollowerPost();
              }
          ),
          ),
          const SizedBox(height: 24),
          NumbersWidget(
            followersCount: followersCount,
                followerText: followerText,
            followers: widget.followers,
              followingCount: followingCount,
            following:widget.following,
          ),
          const SizedBox(height:24),
            Expanded(child: ViewPosts()),
            const Divider(),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    readUserInfo();

  }
  void readUserInfo()async {
    FirebaseFirestore.instance.collection('users').doc(widget.userId)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      widget.following = List.from(snapshot.get('following'));
      setState(() {
        followingCount = (widget.following?.length ?? 0);
      });
      widget.followers = List.from(snapshot.get('followers'));
      setState(() {
        followersCount = (widget.followers?.length ?? 0);
      });

    });
  }
  void readUserInfo2()async {
    FirebaseFirestore.instance.collection('users').doc(followuserId)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      followingx = List.from(snapshot.get('following'));

    });
  }


  handleFollowerPost() {
    if (widget.followers!= null && widget.followers!.contains(followuserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers!.remove(followuserId);
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers!.add(followuserId!);
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'followers': widget.followers!,
    }).then((value) {
      setState(() {
        followersCount = (widget.followers?.length ?? 0);
      });
    });
    Following();
  }
  Following(){
    if (followingx!= null && followingx!.contains(widget.userId)) {
      Fluttertoast.showToast(msg: "You unfollowedx this person");
      followingx!.remove(widget.userId);
    }
    else {
      Fluttertoast.showToast(msg: "You followedx this person");
      followingx!.add(widget.userId!);
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(followuserId)
        .update({'following': followingx!,
    });
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
ViewPosts(){
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
          return const Center(child: Text("This user has is no Posts.",
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
  );
}

}