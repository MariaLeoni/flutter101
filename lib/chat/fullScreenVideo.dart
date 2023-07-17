
import 'package:flutter/material.dart';

class FullScreenVideoView extends StatelessWidget {
  final String url;

  FullScreenVideoView({Key? key, required this.url}) : super(key: key);

  // BetterPlayerController? controller = ReusableVideoListController().getBetterPlayerController();
  // StreamController<BetterPlayerController?>
  // betterPlayerControllerStreamController = StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    _setupController();

    var screen = MediaQuery.of(context).size;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
          width: screen.width,
          height: screen.height * 0.75,
          child:
          // controller != null
          //     ? BetterPlayer(controller: controller!,)
          //     :
          Container(color: Colors.black,
              child: const Center(child: CircularProgressIndicator(valueColor:
            AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
          )
      ),
    );
  }

  void _setupController() {
    // if (controller == null) {
    //   return;
    // }
    // else {
    //     controller!.setupDataSource(BetterPlayerDataSource.network(
    //         url, cacheConfiguration:
    //         const BetterPlayerCacheConfiguration(useCache: true)));
    //     if (!betterPlayerControllerStreamController.isClosed) {
    //       betterPlayerControllerStreamController.add(controller);
    //     }
    //
    //   }
  }
}