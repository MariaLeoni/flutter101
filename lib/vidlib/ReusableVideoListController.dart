import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';

class ReusableVideoListController {
  final List<BetterPlayerController> _betterPlayerControllerRegistry = [];
  final List<BetterPlayerController> _usedBetterPlayerControllerRegistry = [];

  ReusableVideoListController() {
    for (int index = 0; index < 10; index++) {
      _betterPlayerControllerRegistry.add(
        BetterPlayerController(
          const BetterPlayerConfiguration(autoPlay: true, handleLifecycle: false,
              autoDispose: false, fit: BoxFit.fill,
              aspectRatio: 4/3, fullScreenByDefault: false),
        ),
      );
    }
  }

  BetterPlayerController? getBetterPlayerController() {
    final freeController = _betterPlayerControllerRegistry.firstWhereOrNull(
            (controller) =>
        !_usedBetterPlayerControllerRegistry.contains(controller));

    if (freeController != null) {
      _usedBetterPlayerControllerRegistry.add(freeController);
    }

    return freeController;
  }

  void freeBetterPlayerController(BetterPlayerController? betterPlayerController) {
    _usedBetterPlayerControllerRegistry.remove(betterPlayerController);
  }

  void dispose() {
    _betterPlayerControllerRegistry.forEach((controller) {
      controller.dispose();
    });
  }
}