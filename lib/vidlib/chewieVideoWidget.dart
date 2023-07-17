import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoWidget extends StatefulWidget {

  final bool autoPlayAndFullscreen;
  final String url;

  const ChewieVideoWidget({Key? key, required this.url, required this.autoPlayAndFullscreen}) : super(key: key);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}


class VideoWidgetState extends State<ChewieVideoWidget> {
  late VideoPlayerController videoPlayerController ;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
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
            controller: ChewieController(
              videoPlayerController: videoPlayerController,
              aspectRatio: 4 / 3,
              showOptions: false,
              // Prepare the video to be played and display the first frame
              autoInitialize: true,
              looping: false,
              autoPlay: widget.autoPlayAndFullscreen,
              fullScreenByDefault: widget.autoPlayAndFullscreen,
              allowFullScreen: widget.autoPlayAndFullscreen,
              // Errors can occur for example when trying to play a video from a non-existent URL
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
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