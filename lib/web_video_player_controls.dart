import 'dart:async';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_js_player/model/track_type.dart';
import 'package:video_js_player/web_video_player_controller.dart';

class WebVideoPlayerControls extends StatefulWidget {
  final WebVideoPlayerController controller;
  const WebVideoPlayerControls({super.key, required this.controller});

  @override
  State<WebVideoPlayerControls> createState() => _WebVideoPlayerControlsState();
}

class _WebVideoPlayerControlsState extends State<WebVideoPlayerControls> {
  WebVideoPlayerController get controller => widget.controller;

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

  Widget _buildDubbingSubtitleDialog(BuildContext context,
      List<VideoTrack> textTracks, List<VideoTrack> audioTracks) {
    return Theme(
      data: Theme.of(context).copyWith(
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (context) {
            return const Icon(Icons.close);
          },
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: .9),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Subtitle",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Audio",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Close"))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    itemCount: textTracks.length,
                    itemBuilder: (c, i) {
                      var item = textTracks[i];
                      return RadioListTile(
                          value: item.mode,
                          groupValue: "showing",
                          title: Text(item.label ?? ""),
                          onChanged: (c) {
                            controller.changeTextTrack(item.id!);
                            Navigator.pop(context);
                          });
                    },
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    itemCount: audioTracks.length,
                    itemBuilder: (c, i) {
                      var item = audioTracks[i];
                      return RadioListTile(
                          value: item.enabled,
                          groupValue: true,
                          title: Text(item.label ?? ""),
                          onChanged: (c) {
                            controller.changeAudioTracks(item.id!);
                            Navigator.pop(context);
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
                                  if (controller.value.isFullScreen)
                                    IconButton(
                                      onPressed: () {
                                        controller.toggleFullScreenMode();
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  const Spacer(),
                                  if (value.audioTracks?.isNotEmpty == true ||
                                      value.textTracks?.isNotEmpty == true)
                                    IconButton(
                                      onPressed: () {
                                        showGeneralDialog(
                                          // ignore: use_build_context_synchronously
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          pageBuilder: (c, _, __) =>
                                              _buildDubbingSubtitleDialog(
                                            c,
                                            value.textTracks ?? [],
                                            value.audioTracks ?? [],
                                          ),
                                        );
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
                          // if (!value.isTracking)
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 16,
                            child: ProgressBar(
                                progress: Duration(
                                    seconds: value.currentTime.toInt()),
                                total:
                                    Duration(seconds: value.duration.toInt()),
                                buffered: Duration(
                                    seconds:
                                        (value.bufferedPercent * value.duration)
                                            .toInt()),
                                progressBarColor: Colors.red,
                                baseBarColor:
                                    Colors.white.withValues(alpha: 0.24),
                                bufferedBarColor:
                                    Colors.white.withValues(alpha: 0.24),
                                thumbColor: Colors.white,
                                barHeight: 4.0,
                                thumbRadius: 10.0,
                                onSeek: (v) {
                                  controller.seekTo(v.inSeconds.toDouble());
                                },
                                timeLabelTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                timeLabelLocation: TimeLabelLocation.below),
                          )
                        ],
                      );
                    })
                : null));
  }
}
