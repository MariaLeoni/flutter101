import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../following/followers.dart';
import '../forgot_password/components/heading_text.dart';
import '../home_screen/post.dart';
import '../owner_details/owner_details.dart';
import '../profile/profile_screen.dart';
import '../search_post/search_post.dart';
import'package:fluttertoast/fluttertoast.dart';


class  UsersSpecificPostsScreen extends StatefulWidget {
  String? userId;
  String? userName;
  String? docId;
  List<String>? followers = List.empty(growable: true);

  UsersSpecificPostsScreen({super.key,
    this.userId,
    this.userName,
    this.followers,
    this.docId,
  });

  @override
  State<UsersSpecificPostsScreen> createState() => UsersSpecificPostsScreenState();
}

class UsersSpecificPostsScreenState extends State<UsersSpecificPostsScreen> {
  String? followuserId;
  String? myImage;
  String? myName;
  int followersCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;


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
  }


  void readUserInfo()async {
    FirebaseFirestore.instance.collection('users')
        .doc(widget.userId)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async
    {
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
    followuserId = _auth.currentUser?.uid;
    followersCount = (widget.followers?.length ?? 0);

    var followerText = Text(followersCount.toString(),
        style: const TextStyle(fontSize: 20.0,
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
            leading: GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: const Icon(
                  Icons.login_outlined
              ),
            ),

            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPost(),),);
                },
                icon: const Icon(Icons.search),
              ),
              FirebaseAuth.instance.currentUser!.uid == widget.userId
                  ?
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
                },
                icon: const Icon(Icons.person),
              ):
              IconButton(
                onPressed: (){
                  handleFollowerPost();
                  followerText;
                },
                icon: const Icon(Icons.person_add_alt_outlined, color: Colors.red),
              ),
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Followers(
                    followers: widget.followers,
                  )));
                },
                icon: const Icon(Icons.person_search),
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

                    Post post = Post.getPost(snapshot, index);

                    return listViewWidget(post.id, post.image, post.userImage,
                        post.userName, post.createdAt, post.email,
                        post.downloads, post.postId, post.likes, post.description);
                  },
                );
              }
              else{
                return const Center(child: Text("There is no Posts",
                      style: TextStyle(fontSize: 20),)
                );
              }
            }
            return const Center(child: Text(
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

