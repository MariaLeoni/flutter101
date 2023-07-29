import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharedstudent1/vidlib/blocWork/video_player_events.dart';
import 'package:sharedstudent1/vidlib/blocWork/video_player_state.dart';
import '../videoControllerService.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  final VideoControllerService videoControllerService;

  VideoPlayerBloc({Key? key, required this.videoControllerService}) : super(VideoPlayerStateInitial()){
    on<VideoPlayerEvent>(mapEventToState);
  }

  void mapEventToState(VideoPlayerEvent event, Emitter<VideoPlayerState> emit) async {
    if (event is VideoSelectedEvent) {
      emit(VideoPlayerStateLoading());

      try {
        final videoController = await videoControllerService.getControllerForUrl(event.video);
        emit(VideoPlayerStateLoaded(event.video, videoController));
      }
      catch (error) {
        emit(VideoPlayerStateError('An unknown error occurred'));
      }
    }
  }
}