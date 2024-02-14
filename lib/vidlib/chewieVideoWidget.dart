import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoWidget extends StatefulWidget {

  final bool autoPlayAndFullscreen;
  final String url;
  final File? file;

  const ChewieVideoWidget({Key? key, required this.url, required this.autoPlayAndFullscreen, required this.file}) : super(key: key);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}


class VideoWidgetState extends State<ChewieVideoWidget> {
  late VideoPlayerController videoPlayerController ;
  late Future<void> _initializeVideoPlayerFuture;
  ChewieController? _chewieController;
  double aspectRatio = 1.78;

  @override
  void initState() {

    if (widget.file != null){
      videoPlayerController = VideoPlayerController.file(widget.file!);
    }
    else{
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    }
    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((value) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {
        aspectRatio = videoPlayerController.value.aspectRatio > 0 ? videoPlayerController.value.aspectRatio : 1.78;
        initChewieController();
      });
    });

    super.initState();
  }

  void initChewieController() {
    _chewieController = getChewieController();
  }

  ChewieController getChewieController() {
    return ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: aspectRatio,
      showOptions: false,
      // Prepare the video to be played and display the first frame
      autoInitialize: true,
      looping: false,
      autoPlay: widget.autoPlayAndFullscreen,
      fullScreenByDefault: widget.autoPlayAndFullscreen,
      allowFullScreen: widget.autoPlayAndFullscreen,
      // Errors can occur for example when trying to play a video from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text("Sorry, there seems to be an issue with this video",
              style: TextStyle(color: Colors.red), textAlign: TextAlign.center
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Chewie(
            key: PageStorageKey(widget.url),
            controller: _chewieController ?? getChewieController(),
          );
        }
        else {
          return const Center(
            child: CircularProgressIndicator(),);
        }
      },
    );
  }
}