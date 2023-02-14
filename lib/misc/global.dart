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

typedef InterestCallback = void Function(Map<String, List<String>?> interests);

typedef VideoSelected = void Function(VideoListData);

bool checkCanBuildVideo() {
  return true;
}