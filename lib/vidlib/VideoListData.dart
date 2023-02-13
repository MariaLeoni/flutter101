import 'package:sharedstudent1/video/videopost.dart';

class VideoListData {
  final VideoPost post;
  Duration? lastPosition;
  bool? wasPlaying = false;

  VideoListData(this.post);
}