import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/misc/global.dart';

class VideoProvider{

  final FirebaseFirestore firebaseFirestore;

  VideoProvider({required this.firebaseFirestore});

  void getAndCacheVideos(String category) async {
    var videoStream = category == "random" ? firebaseFirestore.collection('wallpaper2')
        .orderBy('createdAt', descending: true).limit(20).snapshots() : firebaseFirestore.collection('wallpaper2')
        .where("category", arrayContains: category).limit(20).snapshots();

    if (await videoStream.isEmpty){
      return;
    }
    else {
      videoStream.forEach((element) {
        String postUrl = Post.getPostUrl(PostType.video, element);
        print("Video Url $postUrl");
      });
    }
  }
}