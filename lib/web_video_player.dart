import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_js_player/web_video_player_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPlayer extends StatefulWidget {
  final WebVideoPlayerController controller;
  const WebPlayer({super.key, required this.controller});
  @override
  State<WebPlayer> createState() => _WebPlayerState();
}

class _WebPlayerState extends State<WebPlayer> {
  WebVideoPlayerController get _videoPlayerController => widget.controller;
  bool _wasPlayingBeforePause = false;

  @override
  Widget build(BuildContext context) {
    return _buildPlayer();
  }

  VisibilityDetector _buildPlayer() {
    return VisibilityDetector(
      key: Key("${_videoPlayerController.hashCode}_key"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          _wasPlayingBeforePause = !_videoPlayerController.value.isPaused;
          _videoPlayerController.pause();
        } else {
          if (_wasPlayingBeforePause &&
              _videoPlayerController.value.isPaused == false) {
            _videoPlayerController.play();
          }
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Container(
                color: Colors.blue,
                child: WebViewWidget(
                    controller: _videoPlayerController.webViewController)),
            if (_videoPlayerController.source?.customControlsBuilder != null)
              _videoPlayerController.source!.customControlsBuilder!
                  .call(_videoPlayerController),
            IconButton(
                onPressed: () {
                  _videoPlayerController.toggleFullScreenMode();
                },
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.red,
                ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.disposeController();
    VisibilityDetectorController.instance
        .forget(Key("${_videoPlayerController.hashCode}_key"));
    super.dispose();
  }
}
