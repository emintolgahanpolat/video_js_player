import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/web_video_player_controller.dart';
import 'package:video_js_player/web_video_player_source.dart';
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
            // initialFile:
            //     _videoPlayerController.source?.sources.firstOrNull?.type ==
            //             WebPlayerVideoSourceType.iframe.typeText
            //         ? null
            //         : "packages/video_js_player/assets/videojs/index.html",
            // initialData:
            //     _videoPlayerController.source?.sources.firstOrNull?.type ==
            //             WebPlayerVideoSourceType.iframe.typeText
            //         ? InAppWebViewInitialData(
            //             data: iframeHtml(_videoPlayerController.source!),
            //             encoding: 'utf-8',
            //             mimeType: 'text/html',
            //           )
            //         : null,

            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              transparentBackground: true,
              disableContextMenu: true,
              supportZoom: false,
              javaScriptCanOpenWindowsAutomatically: true,
              disableHorizontalScroll: false,
              disableVerticalScroll: false,
              allowUniversalAccessFromFileURLs: true,
              allowsInlineMediaPlayback: true,
              allowsAirPlayForMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: true,
              useWideViewPort: false,
            ),
            onLoadStop: (controller, url) {
              _videoPlayerController.updateValue(
                  _videoPlayerController.value.copyWith(isLoad: true));
              _videoPlayerController.evaluateJavascript(
                  source:
                      "player.controls(${_videoPlayerController.source?.customControlsBuilder == null});");

              if (_videoPlayerController.source != null &&
                  _videoPlayerController.source?.sources.first.type !=
                      WebPlayerVideoSourceType.iframe.typeText) {
                if (_videoPlayerController.source?.poster != null) {
                  _videoPlayerController.evaluateJavascript(
                      source:
                          "player.poster('${_videoPlayerController.source?.poster}');");
                }
                _videoPlayerController
                    .src(_videoPlayerController.source!.sources);

                if (_videoPlayerController.source!.autoPlay) {
                  _videoPlayerController.play();
                }
              } else {
                _videoPlayerController.evaluateJavascript(source: """
const iframe = document.createElement("iframe");
iframe.src = "${_videoPlayerController.source!.sources.first.src}";
iframe.width = "100%";
iframe.height = "100%";
document.body.appendChild(iframe);
""");
              }
            },
            onWebViewCreated: (controller) {
              _videoPlayerController.updateValue(
                _videoPlayerController.value.copyWith(
                  webViewController: controller,
                ),
              );

              if (_videoPlayerController.source?.sources.firstOrNull?.type ==
                  WebPlayerVideoSourceType.iframe.typeText) {
                _videoPlayerController.webViewController?.loadFile(
                    assetFilePath:
                        "packages/video_js_player/assets/player/iframe.html");
              } else {
                _videoPlayerController.webViewController?.loadFile(
                    assetFilePath:
                        "packages/video_js_player/assets/player/index.html");
              }
              controller.addJavaScriptHandler(
                handlerName: "error",
                callback: (params) {
                  _videoPlayerController.setError(params[0].toString());
                },
              );
              controller.addJavaScriptHandler(
                handlerName: "close",
                callback: (params) {
                  _videoPlayerController.setClose();
                },
              );
              controller.addJavaScriptHandler(
                  handlerName: "useractive",
                  callback: (params) {
                    _videoPlayerController.updateValue(_videoPlayerController
                        .value
                        .copyWith(isUserActive: params[0]));
                  });
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
