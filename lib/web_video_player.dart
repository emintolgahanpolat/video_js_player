import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_js_player/web_video_player_controller.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPlayer extends StatefulWidget {
  final WebPlayerSource source;
  const WebPlayer({super.key, required this.source});
  @override
  State<WebPlayer> createState() => _WebPlayerState();
}

class _WebPlayerState extends State<WebPlayer> {
  late WebVideoPlayerController _videoPlayerController;
  bool _wasPlayingBeforePause = false;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = WebVideoPlayerController();
    _videoPlayerController.load(widget.source);
  }

  bool _isFullScreen = false;
  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute<void> route = PageRouteBuilder<void>(
      settings: const RouteSettings(),
      pageBuilder: (context, animation, p) => AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: _buildPlayer(),
            ),
          );
        },
      ),
    );

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    await Navigator.of(context, rootNavigator: true).push(route);
    _isFullScreen = false;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    await SystemChrome.setPreferredOrientations([]);
  }

  Future<void> onFullScreenChanged() async {
    if (!_isFullScreen) {
      _isFullScreen = true;

      await _pushFullScreenWidget(context);
    } else if (_isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isFullScreen = false;
    }
  }

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
            if (widget.source.customControlsBuilder != null)
              widget.source.customControlsBuilder!.call(_videoPlayerController),
            IconButton(
                onPressed: () {
                  onFullScreenChanged();
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
