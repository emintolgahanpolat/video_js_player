import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/model/track_type.dart';
import 'package:video_js_player/web_video_player_controller.dart';
import 'package:video_js_player/web_video_player_controls.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef WebPlayerErrorBuilder = Widget Function(
    BuildContext context, String error);
typedef WebPlayerControlsBuilder = Widget Function(
    BuildContext context, WebVideoPlayerController controller);

class WebPlayer extends StatefulWidget {
  final WebVideoPlayerController controller;
  final WebPlayerControlsBuilder? controlsBuilder;
  final WebPlayerErrorBuilder? errorBuilder;
  final Color backgroundColor;
  const WebPlayer({
    super.key,
    required this.controller,
    this.controlsBuilder,
    this.errorBuilder,
    this.backgroundColor = Colors.black,
  });
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
      child: ColoredBox(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            InAppWebView(
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
                    _videoPlayerController.value.copyWith(isReady: true));

                if (_videoPlayerController.source != null &&
                    _videoPlayerController.source?.type !=
                        WebPlayerVideoSourceType.iframe.typeText) {
                  if (_videoPlayerController.source?.poster != null) {
                    _videoPlayerController.evaluateJavascript(
                        source:
                            "player.poster('${_videoPlayerController.source?.poster}');");
                  }
                  _videoPlayerController.src(_videoPlayerController.source!);
                  _videoPlayerController.source!.textTracks?.forEach((item) {
                    _videoPlayerController.addRemoteTextTrack(item);
                  });
                  if (_videoPlayerController.source!.autoPlay) {
                    _videoPlayerController.play();
                  }
                } else {
                  _videoPlayerController.evaluateJavascript(source: """
        const iframe = document.createElement("iframe");
        iframe.src = "${_videoPlayerController.source!.src}";
        iframe.autoPlay = ${_videoPlayerController.source?.autoPlay ?? false} 
        iframe.controls = false;
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

                if (_videoPlayerController.source?.type ==
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
                    _videoPlayerController.updateValue(_videoPlayerController
                        .value
                        .copyWith(errorMessage: params[0]["message"]));
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
                    handlerName: "audioTracks",
                    callback: (params) {
                      debugPrint("audioTracks data:${params[0].toString()}");
                      _videoPlayerController.updateValue(
                          _videoPlayerController.value.copyWith(
                              audioTracks:
                                  VideoTrack.parseVideoTracks(params[0])));
                    });

                controller.addJavaScriptHandler(
                    handlerName: "textTracks",
                    callback: (params) {
                      _videoPlayerController.updateValue(
                          _videoPlayerController.value.copyWith(
                              textTracks:
                                  VideoTrack.parseVideoTracks(params[0])));
                    });
              },
            ),
            ValueListenableBuilder(
                valueListenable: _videoPlayerController,
                builder: (c, snapshot, w) {
                  if (snapshot.errorMessage != null) {
                    return widget.errorBuilder == null
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(24),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _videoPlayerController.value.errorMessage!,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ))
                        : widget.errorBuilder!(
                            c, _videoPlayerController.value.errorMessage!);
                  } else {
                    if (_videoPlayerController.source?.type ==
                            WebPlayerVideoSourceType.iframe.typeText &&
                        widget.controlsBuilder == null) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 8,
                            top: 8,
                            child: IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.3),
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return widget.controlsBuilder == null
                          ? WebVideoPlayerControls(
                              controller: _videoPlayerController)
                          : widget.controlsBuilder!
                              .call(context, _videoPlayerController);
                    }
                  }
                }),
          ],
        ),
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
