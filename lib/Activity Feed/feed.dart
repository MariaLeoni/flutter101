import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../owner_details/owner_details.dart';
import '../search_post/users_specific_posts.dart';
import 'feedpost.dart';

class ActivityFeed extends StatefulWidget {

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  @override
  void initState() {
    super.initState();

    print("ActivityFeed myId: ${_auth.currentUser!.uid}");
  }

  Widget listViewWidget (String Image, String name, String postId, DateTime timestamp, String type,
      String userId, String userProfileImage, String commentData, String description, String postOwnerId, String postOwnername, String postOwnerImage,
      List<String>? likes, int downloads, String ActivityId, bool ReadStatus ) {
    if (type == "like" || type == 'comment'|| type == 'follow'|| type == 'tag' || type =='comment reply') {
      mediaPreview = GestureDetector(
          onTap:() {
            FirebaseFirestore.instance.collection('Activity Feed').doc(_auth.currentUser!.uid).collection('FeedItems').doc(ActivityId).update({'Read Status': true});
            Navigator.push(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
              img: Image, userImg: postOwnerImage, name: postOwnername, date: timestamp, docId: userId,
              userId: postOwnerId,  postId: postId,
              description: description, likes: likes, downloads: downloads,
            )));
          },
          child: Container(
              height: 50.0,
              width: 50.0,
              child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Image),
                        )
                    ),
                  )
              )
          )
      );
    }else{
      mediaPreview = Text('');
    }
    if (type == 'like') {
      ActivityItemText = "liked your post";
    } else if (type == 'comment') {
      ActivityItemText = 'replied : $commentData';
    } else if (type == 'follow') {
      ActivityItemText = ' started following you';
    } else if (type == 'tag'){
      ActivityItemText = ' tagged you in a post ';
    }else if (type == 'comment reply'){
      ActivityItemText = 'replied to your comment: $commentData ';
    }
    else {
      ActivityItemText = "Error : Uknown type '$type'";
    }

    return Padding(
        padding:EdgeInsets.only(bottom: 2.0),
        child: Container(
            color: Colors.white54,
            child: GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance.collection('Activity Items').doc(_auth.currentUser!.uid).collection('FeedItems').doc(ActivityId).update({'Read Status': true });
                },child: ListTile(
              title: GestureDetector(
                  onTap: ()=> print('show profile'),
                  child: RichText(
                      overflow: TextOverflow. ellipsis,
                      text: TextSpan(
                          style: TextStyle(
                            fontSize:14.0,
                            color:Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' $ActivityItemText',

                            ),
                          ]
                      )
                  )
              ),
              leading:
              ReadStatus == false ?
              IconButton(onPressed: () async{

              }, icon: const Icon(Icons.circle, color: Colors.red)):
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) =>
                      UsersSpecificPostsScreen(
                        userId: userId,
                        userName: name,
                      )));
                },
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(userProfileImage),
                ),
              ),
              // ReadStatus == false ?
              // IconButton(onPressed: () async{
              //
              // }, icon: const Icon(Icons.circle, color: Colors.red)): Container(),
              subtitle: Text(
                DateFormat("dd MMM, yyyy - hh:mn a").format(timestamp).toString(),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: mediaPreview,
            )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
      flexibleSpace:Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.2],
          ),
        ),
      ),
      title:const Text('Activity Feed',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Activity Feed').doc(_auth.currentUser!.uid).collection('FeedItems')
            .orderBy('timestamp', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (snapshot.connectionState == ConnectionState.active) {
            if(snapshot.data!.docs.isNotEmpty){
              {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    FeedPost post = FeedPost.getPost(snapshot, index);

                    return listViewWidget(post.image, post.name, post.postId, post.timestamp,post.type,
                      post.userId, post.userProfileImage, post.commentData, post. description, post.postOwnerId, post.postOwnerName, post.postOwnerImage, post.likes, post.downloads, post.activityId,post.readStatus,
                    );
                  },
                );
              }
            }
            else {
              return const Center(
                  child: Text("There are no Activities",
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
    );
  }
}
Widget? mediaPreview;
String? ActivityItemText;
