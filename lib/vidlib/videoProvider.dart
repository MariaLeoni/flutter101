import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/vidlib/videoControllerService.dart';

class VideoProvider{

  final FirebaseFirestore firebaseFirestore;
  final cacheSystem = CachedVideoControllerService(DefaultCacheManager());

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
        cacheSystem.cacheFileForUrl(postUrl);
        print("Video Url $postUrl");
      });
    }
  }
}