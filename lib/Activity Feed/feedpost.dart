import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FeedPost {
  String Image= "";
  String name = "";
  String postId = "";
  String ActivityId = "";
  String type = "";
  DateTime timestamp = DateTime.now();
  String userId = "";
  String userProfileImage = "";
  String commentData = "";
 String description = "";
 int downloads = 0;
String postOwnerId = "";
String postOwnerImage = "";
String postOwnername = "";
  List<String>? likes = List.empty(growable: true);
bool ReadStatus;


  FeedPost({
    required this.Image,
    required this.name,
    required this.postId,
    required this.ActivityId,
    required this.type,
    required this.timestamp,
    required this.userId,
    required this.userProfileImage,
   required this.commentData,
    required this. description,
    required this.downloads,
    required this.postOwnerId,
    required this.postOwnerImage,
    required this.postOwnername,
    required this.likes,
    required this.ReadStatus,


  });

  static FeedPost getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index) {
    return FeedPost(
        Image: snapshot.data!.docs[index]['Image'],
       name: snapshot.data!.docs[index]['name'],
        postId: snapshot.data!.docs[index]['postId'],
      ActivityId: snapshot.data!.docs[index]['Activity Id'],
      timestamp: snapshot.data!.docs[index]['timestamp'].toDate(),
        type: snapshot.data!.docs[index]['type'],
      userId: snapshot.data!.docs[index]['userId'],
        userProfileImage: snapshot.data!.docs[index]['userProfileImage'],
       commentData: snapshot.data!.docs[index]['commentData'],
      description: snapshot.data!.docs[index]['description'],
      downloads:snapshot.data!.docs[index]['downloads'],
      postOwnerId:snapshot.data!.docs[index]['postOwnerId'],
      postOwnerImage:snapshot.data!.docs[index]['postOwnerImage'],
      postOwnername:snapshot.data!.docs[index]['postOwnername'],
    likes: List.from(snapshot.data!.docs[index]['likes']),
      ReadStatus:snapshot.data!.docs[index]['Read Status'],
    );
  }
}