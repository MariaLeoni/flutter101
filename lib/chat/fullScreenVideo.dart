
import 'package:flutter/material.dart';
import '../vidlib/chewieVideoWidget.dart';

class FullScreenVideoView extends StatelessWidget {
  final String url;
  const FullScreenVideoView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
          width: screen.width,
          height: screen.height * 0.75,
          child: ChewieVideoWidget(autoPlayAndFullscreen: true, url: url,),
          )
    );
  }
}