import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sharedstudent1/vidlib/VideoListData.dart';
import 'package:video_compress/video_compress.dart';
import '../search_post/user.dart';
import 'package:http/http.dart' as http;

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

String getFileName(String url, PostType type){
  var filePath = type == PostType.video ? url.split("userVideos") : url.split("userImages");
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

Future<Users?> getUserWithEmail(String email) async {
  final user = FirebaseFirestore.instance.collection('users')
      .where("email", isEqualTo: email).get();
  var userModel = await user;
  return Users.fromJson(userModel.docs.first.data());
}

Future<void> deleteUser(Users user)async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'deleteUser',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 10),
      )
  );

  try {
    final result = await callable.call(<String, dynamic>{
      'email': user.email,'coll': 'users'
    });
    print("Cloud function results ${result.data as String}");
  } catch (e) {
    print("Cloud function  ERROR: ${e.toString()}");
  }

  signOutUser();
}

void signOutUser(){
  FirebaseAuth.instance.signOut();
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
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

void downloadAndShare(String fileUrl, String description, PostType type) async {
  const appName = "Shared from TheGist App";
  String typeString = type == PostType.image ? "image.jpg" : "video.mp4";
  final url = Uri.parse(fileUrl);
  final response = await http.get(url);
  final bytes = response.bodyBytes;

  final temp = await getTemporaryDirectory();
  final path = '${temp.path}/$typeString';
  File(path).writeAsBytesSync(bytes);

  await Share.shareXFiles([XFile(path)], text: description, subject: appName);
}
// void Snackbar(String message) async{
//   ScaffoldMessenger.of(context as BuildContext)
//       .showSnackBar(const SnackBar(content: Text('$message')));
//   return;
// }


Future<File?> getProcessedFile(File? mediaFile) async {
  File processedFile;
  if (mediaFile == null) {
    return null;
  }
  if (Platform.isIOS) {
    processedFile = mediaFile;
  }
  else{
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(mediaFile.path,
      quality: VideoQuality.HighestQuality, deleteOrigin: false,);
    if (mediaInfo != null && mediaInfo.file != null){
      processedFile = mediaInfo.file!;
    }
    else {
      processedFile = mediaFile;
    }
  }

  return processedFile;
}

