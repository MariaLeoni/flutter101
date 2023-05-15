import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sharedstudent1/vidlib/VideoListData.dart';

Future<File> getImageFileFromAssets(String path) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var filePath = "$tempPath/$path";
  var file = File(filePath);
  if (file.existsSync()) {
    return file;
  } else {
    final byteData = await rootBundle.load('assets/$path');
    final buffer = byteData.buffer;
    await file.create(recursive: true);
    return file.writeAsBytes(buffer
        .asUint8List(byteData.offsetInBytes,
        byteData.lengthInBytes));
  }
}

String getFileName(String url){
  var filePath = url.split("userVideos");
  var name = filePath[1].split("?alt");
  var fileName = name[0];
  var fileNameDecoded = Uri.decodeFull(fileName);
  return fileNameDecoded;
}

Future<bool> usernameExist(String username) async {
  final usersWithUserName = FirebaseFirestore.instance.collection('users')
                            .where("name", isEqualTo: username).count();
  final AggregateQuerySnapshot snapshot = await usersWithUserName.get();
  return snapshot.count > 0 ? true : false;
}

enum PostType{
  image,
  video,
  text
}

enum SearchType{
  user,
  post,
}

enum FFType{
  follower,
  following
}

enum FeedType{
  like("like"),
  comment("comment"),
  follow("follow"),
  tag("tag"),
  reply("commentReply");

  const FeedType(this.value);
  final String value;
}

typedef InterestCallback = void Function(Map<String, List<String>?> interests);

typedef VideoSelected = void Function(VideoListData);

typedef GoToPageWithTypeAndId = void Function(dynamic type, String Id);

List<String> images = ['jpeg', 'jpg', 'png', 'gif', 'tiff'];
List<String> videos = ['mp4', 'mov', 'wmv', 'avi', 'mkv'];

bool checkCanBuildVideo() {
  return true;
}

