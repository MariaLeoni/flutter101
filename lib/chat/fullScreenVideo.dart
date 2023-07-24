import 'package:flutter/material.dart';
import '../vidlib/chewieVideoWidget.dart';

class FullScreenVideoView extends StatelessWidget {
  final String url;
  const FullScreenVideoView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            flexibleSpace:Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
        ),
        body: Center(child: SizedBox.fromSize(
          size: Size(screen.width, screen.height * 0.65), // Image border
          child: ChewieVideoWidget(autoPlayAndFullscreen: false, url: url, file: null,),),)
    );
  }
}