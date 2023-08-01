import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class VideoControllerService {
  Future<VideoPlayerController> getControllerForUrl(String video);
  Future<void> cacheFileForUrl(String video);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getControllerForUrl(String video) async{
    final fileInfo = await _cacheManager.getFileFromCache(video);

    if (fileInfo == null) {
      print('[VideoControllerService]: No video in cache');

      print('[VideoControllerService]: Saving video to cache');
      unawaited(_cacheManager.downloadFile(video));

      return VideoPlayerController.networkUrl(Uri.parse(video));
    } else {
      print('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(fileInfo.file);
    }
  }

  @override
  Future<void> cacheFileForUrl(String video) async {
    final fileInfo = await _cacheManager.getFileFromCache(video);
    if (fileInfo == null) {
      print('[VideoControllerService]: No video in cache');

      print('[VideoControllerService]: Saving video to cache');
      unawaited(_cacheManager.downloadFile(video));
    } else {
      return;
    }
  }
}