import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:sharedstudent1/misc/global.dart';
import '../following/follows.dart';
import '../home_screen/home.dart';
import '../home_screen/post.dart';
import '../owner_details/owner_details.dart';
import '../profile/profile_screen.dart';
import'package:fluttertoast/fluttertoast.dart';
import '../search_userpost/searchView.dart';


class UserProfile extends StatefulWidget {
  String? userId;
  String? userName;
  List<String>? followers = List.empty(growable: true);

  UserProfile({super.key,
    this.userId,
    this.userName,
    this.followers,
  });

  @override
  State<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String? followUserId;
  String? myImage;
  String? myName;
  int followersCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  handleFollowerPost() {
    if (widget.followers!= null && widget.followers!.contains(followUserId)) {
      Fluttertoast.showToast(msg: "You unfollowed this person");
      widget.followers!.remove(followUserId);
    }
    else {
      Fluttertoast.showToast(msg: "You followed this person");
      widget.followers!.add(followUserId!);
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'followers': widget.followers!,
    }).then((value) {
      setState(() {
        followersCount = (widget.followers?.length ?? 0);
      });
    });
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users').doc(widget.userId)
        .get().then<dynamic>((DocumentSnapshot snapshot) async {
            myImage = snapshot.get('userImage');
            myName = snapshot.get('name');
            widget.followers = List.from(snapshot.get('followers'));

            setState(() {
              followersCount = (widget.followers?.length ?? 0);
            });
    });
  }

  @override
  void initState() {
    super.initState();
    readUserInfo();
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
                              Text(DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
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
    followUserId = _auth.currentUser?.uid;
    followersCount = (widget.followers?.length ?? 0);

    var followerText = Text(followersCount.toString(),
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            flexibleSpace:Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
            title: Text(myName!,),
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
                icon: const Icon(Icons.person_search),
              ),
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
                },
                icon: const Icon(Icons.person),
              ),
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Follows(
                    follow: widget.followers, user: myName ?? "", type: FFType.follower,
                  )));
                },
                icon: const Icon(Icons.check_circle_sharp),
              ),
              followerText,

              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
                },
                icon: const Icon(Icons.home),
              ),
            ]

        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('wallpaper')
              .where("id", isEqualTo: _auth.currentUser!.uid)
              .orderBy('createdAt',descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {

                    Post post = Post.getPost(snapshot, index, PostType.image);

                    return listViewWidget(post.id, post.source, post.userImage,
                        post.userName, post.createdAt, post.email,
                        post.downloads, post.postId, post.likes,post.description);
                  },
                );
              }
              else{
                return const Center(
                    child: Text("There is no tasks", style: TextStyle(fontSize: 20),)
                );
              }
            }
            return const Center(
              child: Text('Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}