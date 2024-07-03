import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_js_player/web_video_player_controller.dart';

class CustomWebPlayerController extends StatefulWidget {
  const CustomWebPlayerController(
    this.controller, {
    super.key,
  });

  final WebVideoPlayerController controller;

  @override
  State<CustomWebPlayerController> createState() =>
      _CustomWebPlayerControllerState();
}

class _CustomWebPlayerControllerState extends State<CustomWebPlayerController> {
  WebVideoPlayerController get controller => widget.controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool controlVisible = true;
  Timer? timer;
  void _handlerGesture() {
    setState(() {
      controlVisible = !controlVisible;
    });
    autoHide();
  }

  void autoHide() {
    if (controlVisible) {
      timer = Timer(const Duration(seconds: 5),
          () => setState(() => controlVisible = false));
    } else {
      timer?.cancel();
    }
  }

  String _formatDuration(double duration) {
    int totalSeconds = duration.toInt();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  Widget _buildDubbingSubtitleDialog(
      BuildContext context, List<dynamic> dubbings, List<dynamic> subTracks) {
    return Theme(
      data: Theme.of(context).copyWith(
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (context) {
            return const Icon(Icons.close);
          },
        ),
      ),
      child: Scaffold(
        appBar: AppBar(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const ListTile(
                    title: Text("Text"),
                  ),
                  Expanded(
                    child: Builder(builder: (mContext) {
                      return ListView.builder(
                        itemCount: dubbings.length,
                        itemBuilder: (c, i) {
                          var item = dubbings[i];
                          return RadioListTile(
                              value: item["mode"],
                              groupValue: "showing",
                              title: Text(item["label"]),
                              onChanged: (c) {
                                controller.changeTextTrack(item["id"]);
                                Navigator.pop(mContext);
                              });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const ListTile(
                    title: Text("Audio"),
                  ),
                  Expanded(
                    child: Builder(builder: (mContext) {
                      return ListView.builder(
                        itemCount: subTracks.length,
                        itemBuilder: (c, i) {
                          var item = subTracks[i];
                          return RadioListTile(
                              value: item["enabled"],
                              groupValue: true,
                              title: Text(item["label"]),
                              onChanged: (c) {
                                controller.changeAudioTracks(item["id"]);
                                Navigator.pop(mContext);
                              });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: _handlerGesture,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: controlVisible
                ? ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      return Stack(
                        children: [
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Center(
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.toggleFullScreenMode();
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      Future.wait([
                                        controller.textTracks(),
                                        controller.audioTracks()
                                      ]).then((futureValue) {
                                        showGeneralDialog(
                                          context: context,
                                          barrierColor:
                                              Colors.black12.withOpacity(0.9),
                                          pageBuilder: (c, _, __) =>
                                              _buildDubbingSubtitleDialog(
                                                  c,
                                                  futureValue.first,
                                                  futureValue.last),
                                        );
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.subtitles,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      value.isFullScreen
                                          ? controller.exitFullscreen()
                                          : controller.requestFullscreen();
                                    },
                                    icon: const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      value.isInPictureInPicture
                                          ? controller.exitPictureInPicture()
                                          : controller
                                              .requestPictureInPicture();
                                    },
                                    icon: const Icon(
                                      Icons.picture_in_picture,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  if (!value.isTracking)
                                    IconButton(
                                      onPressed: () {
                                        controller
                                            .seekTo(value.currentTime - 10);
                                      },
                                      icon: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: () {
                                      value.isPaused
                                          ? controller.play()
                                          : controller.pause();
                                    },
                                    icon: value.isPaused
                                        ? const Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 36,
                                            color: Colors.white,
                                          ),
                                  ),
                                  if (!value.isTracking)
                                    IconButton(
                                      onPressed: () {
                                        controller
                                            .seekTo(value.currentTime + 10);
                                      },
                                      icon: const Icon(
                                        Icons.forward_10,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!value.isTracking)
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 8,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value:
                                          (value.currentTime / value.duration)
                                              .clamp(0, 1),
                                      min: 0,
                                      max: 1,
                                      onChanged: (v) {
                                        controller.seekTo(v * value.duration);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '${_formatDuration(value.currentTime)}/${_formatDuration(value.duration)}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                        ],
                      );
                    })
                : null));
  }
}
