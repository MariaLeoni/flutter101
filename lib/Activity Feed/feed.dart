import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../owner_details/owner_details.dart';
import 'feedpost.dart';
class ActivityFeed extends StatefulWidget {



  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  FirebaseAuth _auth =FirebaseAuth.instance;
  // getActivityFeed() async{
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ActivityFeed').doc(_auth.currentUser!.uid).collection('FeedItems')
  //       .orderBy('timestamp', descending:true)
  //       .limit(50)
  //       .get();
  //   // List<ActivityFeedItem> followers = [];
  //   // for (var doc in snapshot.data!.docs) {
  //   //   followers.add(ActivityFeedItem.fromDocument(doc));
  //   List <ActivityFeedItem> feedItems = [];
  //    snapshot.docs.forEach((doc){
  //      feedItems.add(ActivityFeedItem.fromDocument(doc));
  //   });
  //    return feedItems;
  //   //   print('Activity Feed Item: ${doc.data}');
  //   // });
  //   return snapshot.docs;
  // }

  Widget listViewWidget (String Image, String name, String postId, DateTime timestamp, String type,
      String userId, String userProfileImage, String commentData, String description, String postOwnerId, String postOwnername, String postOwnerImage,
      List<String>? likes, int downloads ) {
    if (type == "like" || type == 'comment'|| type == 'follow') {
      mediaPreview = GestureDetector(
          onTap:() {
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
    } else {
      ActivityItemText = "Error : Uknown type '$type'";
    }

    return Padding(
        padding:EdgeInsets.only(bottom: 2.0),
        child: Container(
            color: Colors.white54,
            child:ListTile(
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

                            )
                          ]
                      )
                  )
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userProfileImage),
              ),
              subtitle: Text(
                DateFormat("dd MMM, yyyy - hh:mn a").format(timestamp).toString(),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: mediaPreview,
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
      title:Text('Activity Feed',
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Activity Feed').doc(_auth.currentUser!.uid).collection('FeedItems')
              .orderBy('timestamp',descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty){
                {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      FeedPost post = FeedPost.getPost(snapshot, index);

                      return listViewWidget(post.Image, post.name, post.postId, post.timestamp,post.type,
                           post.userId, post.userProfileImage, post.commentData, post. description, post.postOwnerId, post.postOwnername, post.postOwnerImage, post.likes, post.downloads,
                      );
                    },
                  );
                }
              }
              else {
                return const Center(
                    child: Text("There are no Actvities",
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
    //  body: Container(
    //     child: FutureBuilder(
    //       future: getActivityFeed(), builder:(context, snapshot){
    //         if(!snapshot.hasData){
    //           return CircularProgressIndicator();
    //         }
    //         return ListView(
    //           children: snapshot.data,);
    //
    //     }
    //     )
    // )
    );
  }
}
Widget? mediaPreview;
String? ActivityItemText;
//
// class ActivityFeedItem extends StatelessWidget {
//   final String name;
//   final String userId;
//   final String type;
//   final String Image;
//   final String postId;
//   final String userProfileImg;
//   final String commentData;
//   final Timestamp timestamp;
//   String? img;
//   ActivityFeedItem({
//     required this.name,
//     required this.userId,
//     required this.type,
//     required this.Image,
//     required this.postId,
//     required this.userProfileImg,
//     required this.commentData,
//     required this.timestamp,
//     this.img,
// });
//
//   factory  ActivityFeedItem.fromDocument(DocumentSnapshot doc){
//     return ActivityFeedItem(
//       name: doc.data().toString().contains('name') ? doc.get(
//           'name') : '',
//       userId: doc.data().toString().contains('userId') ? doc.get(
//           'userId') : '',
//       type:doc.data().toString().contains('type') ? doc.get(
//           'type') : '',
//         postId:doc.data().toString().contains('postId') ? doc.get(
//             'postId') : '',
//         userProfileImg:doc.data().toString().contains('userProfileImg') ? doc.get(
//             'userProfileImg') : '',
//         commentData: doc.data().toString().contains('commentData') ? doc.get(
//             'commentData') : '',
//       timestamp: doc.data().toString().contains('timestamp') ? doc.get(
//           'timestamp') : '',
//       Image: doc.data().toString().contains('Image') ? doc.get(
//           'Image') : '',
//     );
//   }
//
//   configureMediaPreview(){
//     if (type == "like" || type == 'comment') {
//       mediaPreview = GestureDetector(
//           onTap: () => print('showing post'),
//           child: Container(
//               height: 50.0,
//               width: 50.0,
//               child: AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: Container(
//                     decoration: BoxDecoration(
//                         image: DecorationImage(
//                           fit: BoxFit.cover,
//                           image: CachedNetworkImageProvider(Image),
//                         )
//                     ),
//                   )
//               )
//           )
//       );
//     }else{
//       mediaPreview = Text('');
//     }
//     if (type == 'like') {
//       ActivityItemText = "liked your post";
//     } else if (type == 'follow'){
//       ActivityItemText = 'replied : $commentData';
//     } else {
//       ActivityItemText = "Error : Uknown type '$type'";
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     configureMediaPreview();
//
//     return Padding(
//       padding:EdgeInsets.only(bottom: 2.0),
//       child: Container(
//         color: Colors.white54,
//         child:ListTile(
//           title: GestureDetector(
//             onTap: ()=> print('show profile'),
//             child: RichText(
//               overflow: TextOverflow. ellipsis,
//               text: TextSpan(
//                 style: TextStyle(
//                   fontSize:14.0,
//                   color:Colors.black,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: name,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   TextSpan(
//                     text: ' $ActivityItemText',
//
//                   )
//                 ]
//               )
//             )
//           ),
//           leading: CircleAvatar(
//             backgroundImage: CachedNetworkImageProvider(userProfileImg),
//           ),
//           subtitle: Text(
//             DateFormat("dd MMM, yyyy - hh:mn a").format(DateTime.now()).toString(),
//             overflow: TextOverflow.ellipsis,
//           ),
//           trailing: mediaPreview,
//         )
//       )
//     );
//   }
// }
