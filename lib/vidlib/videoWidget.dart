import 'dart:async';
import 'dart:math';
import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'ReusableVideoListController.dart';
import 'VideoListData.dart';

class VideoItemWidget extends StatefulWidget {
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final VideoListData videoInfo;
  final ReusableVideoListController? videoListController;
  final void Function()? videoEnded;
  final Function? canBuildVideo;

  const VideoItemWidget({super.key,
    required this.videoInfo,
    required this.pageIndex,
    required this.currentPageIndex,
    required this.isPaused,
    this.videoEnded,
    this.videoListController,
    this.canBuildVideo,
  });

  @override
  State<StatefulWidget> createState() => VideoItemWidgetState();
}

class VideoItemWidgetState extends State<VideoItemWidget>{
  //late VideoPlayerController? _videoPlayerController;
  VideoListData? get videoData => widget.videoInfo;
  bool _initialized = false;
  Timer? _timer;

  BetterPlayerController? controller;
  StreamController<BetterPlayerController?>
  betterPlayerControllerStreamController = StreamController.broadcast();

  @override
  void dispose() {
    betterPlayerControllerStreamController.close();
    super.dispose();
  }

  void _setupController() {
    print("_setupController");
    if (controller == null) {
      controller = widget.videoListController!.getBetterPlayerController();
      if (controller != null) {
        print("Source ${videoData!.post.source}");
        controller!.setupDataSource(BetterPlayerDataSource.network(
            videoData!.post.source,
            cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: true)));
        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }
        controller!.addEventsListener(onPlayerEvent);
      }
    }
  }

  void _freeController() {
    if (!_initialized) {
      _initialized = true;
      return;
    }
    if (controller != null && _initialized) {
      controller!.removeEventsListener(onPlayerEvent);
      widget.videoListController!.freeBetterPlayerController(controller);
      controller!.pause();
      controller = null;
      if (!betterPlayerControllerStreamController.isClosed) {
        betterPlayerControllerStreamController.add(null);
      }
      _initialized = false;
    }
  }

  void onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      widget.videoInfo.lastPosition = event.parameters!["progress"] as Duration?;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (widget.videoInfo.lastPosition != null) {
        controller!.seekTo(widget.videoInfo.lastPosition!);
      }
      if (widget.videoInfo.wasPlaying!) {
        controller!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;
    print("Size $tmp");
    return _renderPortraitVideo(tmp);
  }

  Widget _renderPortraitVideo(Size tmp) {
    print("A isInit $_initialized and controller null ${controller == null}");
    if (controller == null) _setupController();

    double height = tmp.height * 0.75;
    var screenH = max(height, tmp.width);
    var screenW = min(height, tmp.width);

    tmp = controller!.videoPlayerController!.value.size == null ? tmp : controller!.videoPlayerController!.value.size!;

    height = tmp.height * 0.75;
    var previewH = max(height, tmp.width);
    var previewW = min(height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Center(
      child: OverflowBox(
          maxHeight: screenRatio > previewRatio
              ? screenH
              : screenW / previewW * previewH,
          maxWidth: screenRatio > previewRatio
              ? screenH / previewH * previewW
              : screenW,
          child: VisibilityDetector(
              onVisibilityChanged: _handleVisibilityDetector,
              key: Key('key_${widget.currentPageIndex}'),
              child: StreamBuilder<BetterPlayerController?>(
                stream: betterPlayerControllerStreamController.stream,
                builder: (context, snapshot) {
                  return controller != null
                      ? BetterPlayer(controller: controller!,)
                      : Container(color: Colors.black, child: const Center(
                    child: CircularProgressIndicator(valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ));
                },
              ))),
    );
  }

  void _handleVisibilityDetector(VisibilityInfo info) {
    if (!widget.canBuildVideo!()) {
      _timer?.cancel();
      _timer = null;
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (info.visibleFraction >= 0.7) {
          _setupController();
        } else {
          _freeController();
        }
      });
      return;
    }
    if (info.visibleFraction >= 0.7) {
      _setupController();
    } else {
      _freeController();
    }
  }
  @override
  void deactivate() {
    if (controller != null) {
      videoData!.wasPlaying = controller!.isPlaying();
    }
    _initialized = true;
    super.deactivate();
  }
}