import 'package:equatable/equatable.dart';

abstract class VideoPlayerEvent extends Equatable{
  @override
  List<Object> get props => const [];
}

class VideoSelectedEvent extends VideoPlayerEvent{
  final String video;

  VideoSelectedEvent(this.video);

  @override
  List<Object> get props => [video];
}