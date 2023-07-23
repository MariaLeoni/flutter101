import 'package:flutter/material.dart';
import '../vidlib/chewieVideoWidget.dart';

class FullScreenVideoView extends StatelessWidget {
  final String url;
  const FullScreenVideoView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return SizedBox.fromSize(
      size: Size(screen.width, screen.height * 0.65), // Image border
      child: ChewieVideoWidget(autoPlayAndFullscreen: true, url: url, file: null,),);
  }
}