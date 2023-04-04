import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FeedPost {
  String image= "";
  String name = "";
  String postId = "";
  String activityId = "";
  String type = "";
  DateTime timestamp = DateTime.now();
  String userId = "";
  String userProfileImage = "";
  String commentData = "";
  String description = "";
  int downloads = 0;
  String postOwnerId = "";
  String postOwnerImage = "";
  String postOwnerName = "";
  List<String>? likes = List.empty(growable: true);
  bool readStatus;

  FeedPost({
    required this.image,
    required this.name,
    required this.postId,
    required this.activityId,
    required this.type,
    required this.timestamp,
    required this.userId,
    required this.userProfileImage,
    required this.commentData,
    required this. description,
    required this.downloads,
    required this.postOwnerId,
    required this.postOwnerImage,
    required this.postOwnerName,
    required this.likes,
    required this.readStatus,
  });

  static FeedPost getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index) {
    return FeedPost(
      image: snapshot.data!.docs[index]['Image'] ?? "",
      name: snapshot.data!.docs[index]['name'] ?? "",
      postId: snapshot.data!.docs[index]['postId'],
      activityId: snapshot.data!.docs[index].toString().contains('Activity Id') ? snapshot.data!.docs[index]['Activity Id'] : "",
      timestamp: snapshot.data!.docs[index]['timestamp'].toDate(),
      type: snapshot.data!.docs[index]['type'] ?? "",
      userId: snapshot.data!.docs[index]['userId'],
      userProfileImage: snapshot.data!.docs[index]['userProfileImage'],
      commentData: snapshot.data!.docs[index]['commentData'] ?? "",
      description: snapshot.data!.docs[index]['description'] ?? "",
      downloads:snapshot.data!.docs[index]['downloads'],
      postOwnerId:snapshot.data!.docs[index]['postOwnerId'],
      postOwnerImage:snapshot.data!.docs[index]['postOwnerImage'],
      postOwnerName:snapshot.data!.docs[index]['postOwnername'],
      likes: List.from(snapshot.data!.docs[index]['likes']),
      readStatus: snapshot.data!.docs[index].toString().contains('Read Status') ? snapshot.data!.docs[index]['Read Status'] : false,
    );
  }
}