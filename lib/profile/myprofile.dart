import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/home_screen/homescreen.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import '../following/followers.dart';
import '../owner_details/owner_details.dart';
import '../profile/profile_screen.dart';
import '../search_post/search_post.dart';
import'package:fluttertoast/fluttertoast.dart';


class  myprofile extends StatefulWidget {
  String? userId;
  String? userName;
  String? docId;
  List<String>? followers = List.empty(growable: true);

  myprofile({super.key,
    this.userId,
    this.userName,
    this.followers,
    this.docId,
  });

  @override
  State<myprofile> createState() => _myprofileState();
}

class _myprofileState extends State<myprofile> {
  String? followuserId;
  String? myImage;
  String? myName;
  int followersCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  handlefollowerPost() {

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
        .doc(_auth.currentUser!.uid)
        .update({'followers': widget.followers!,
    }).then((value) {
      setState(() {
        followersCount = (widget.followers?.length ?? 0);
      });
    });
  }


  void readUserInfo()async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(_auth.currentUser!.uid)
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

  Widget listViewWidget (String docId, String img, String userImg, String name, DateTime date, String userId, int downloads, )
  {
    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap:()
                  {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
                      img: img,
                      userImg: userImg,
                      name: name,
                      date: date,
                      docId: docId,
                      userId: userId,
                      downloads: downloads,
                    )));
                  },
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                  ) ,
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
        style: const TextStyle(fontSize: 28.0,
            color: Colors.white, fontWeight: FontWeight.bold));
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.deepPurple.shade300],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
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
            title: Text(
              myName!,
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: ()
              {
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
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPost(),),);
                },
                icon: const Icon(Icons.person_search),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
                },
                icon: const Icon(Icons.person),
              ),
              IconButton(
                onPressed: (){

                  Navigator.push(context, MaterialPageRoute(builder: (_) => Followers(
                    followers: widget.followers,
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
          stream: FirebaseFirestore.instance
              .collection('wallpaper')
              .where("id", isEqualTo: _auth.currentUser!.uid)
              .orderBy('createdAt',descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting )
            {
              return Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active)
            {
              if(snapshot.data!.docs.isNotEmpty)
              {


                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index)
                  {
                    return listViewWidget(
                      snapshot.data!.docs[index].id,
                      snapshot.data!.docs[index]['Image'],
                      snapshot.data!.docs[index]['userImage'],
                      snapshot.data!.docs[index]['name'],
                      snapshot.data!.docs[index]['createdAt'].toDate(),
                      snapshot.data!.docs[index]['email'],
                      snapshot.data!.docs[index]['downloads'],
                    );
                  },
                );
              }
              else{
                return const Center(
                    child: Text("There is no tasks",
                      style: TextStyle(fontSize: 20),)
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