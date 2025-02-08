import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/web_video_player_controller.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:video_js_player/web_video_player_util.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  void initState() {
    // _videoPlayerController.updateValue(_videoPlayerController.value.copyWith(
    //   webViewController: null,
    // ));
    super.initState();
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
      child: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _videoPlayerController.source!.type ==
                      WebPlayerSourceType.videoJs
                  ? videoJsHtml(_videoPlayerController.source!)
                  : iframeHtml(_videoPlayerController.source!),
              encoding: 'utf-8',
              mimeType: 'text/html',
            ),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              transparentBackground: true,
              disableContextMenu: true,
              supportZoom: false,
              disableHorizontalScroll: false,
              disableVerticalScroll: false,
              allowsInlineMediaPlayback: true,
              allowsAirPlayForMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: true,
              useWideViewPort: false,
            ),
            onWebViewCreated: (controller) {
              _videoPlayerController.updateValue(
                _videoPlayerController.value.copyWith(
                  webViewController: controller,
                ),
              );

              controller.addJavaScriptHandler(
                handlerName: "error",
                callback: (params) {
                  _videoPlayerController.setError(params[0]);
                },
              );
              controller.addJavaScriptHandler(
                  handlerName: "pause",
                  callback: (params) {
                    _videoPlayerController.updateValue(_videoPlayerController
                        .value
                        .copyWith(isPaused: params[0]));
                  });
              controller.addJavaScriptHandler(
                  handlerName: "currentTime",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      currentTime: double.parse("${params[0]}"),
                    ));
                  });

              controller.addJavaScriptHandler(
                  handlerName: "bufferedPercent",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      bufferedPercent: double.parse("${params[0]}"),
                    ));
                  });

              controller.addJavaScriptHandler(
                  handlerName: "durationchange",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      duration: double.parse("${params[0]}"),
                    ));
                  });

              controller.addJavaScriptHandler(
                  handlerName: "isTracking",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      isTracking: params[0],
                    ));
                  });
              controller.addJavaScriptHandler(
                  handlerName: "enterpictureinpicture",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      isFullScreen: params[0],
                    ));
                  });

              controller.addJavaScriptHandler(
                  handlerName: "durationchange",
                  callback: (params) {
                    _videoPlayerController
                        .updateValue(_videoPlayerController.value.copyWith(
                      duration: double.parse("${params[0]}"),
                    ));
                  });

              controller.addJavaScriptHandler(
                  handlerName: "audioTracks", callback: (params) {});
            },
          ),
          if (_videoPlayerController.source?.customControlsBuilder != null)
            _videoPlayerController.source!.customControlsBuilder!
                .call(_videoPlayerController),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    VisibilityDetectorController.instance
        .forget(Key("${_videoPlayerController.hashCode}_key"));
    super.dispose();
  }
}
