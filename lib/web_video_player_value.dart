import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/model/track_type.dart';

class WebPlayerValue {
  final InAppWebViewController? webViewController;
  double currentTime;
  double duration;
  double bufferedPercent;
  bool isPaused;
  bool isFullScreen;
  bool isInPictureInPicture;
  bool isTracking;
  bool isCover;
  bool isUserActive;
  bool isReady;
  String? errorMessage;
  List<VideoTrack>? textTracks;
  List<VideoTrack>? audioTracks;
  WebPlayerValue({
    this.currentTime = 0,
    this.duration = 0,
    this.bufferedPercent = 0,
    this.isPaused = true,
    this.isFullScreen = false,
    this.isInPictureInPicture = false,
    this.isTracking = false,
    this.isCover = false,
    this.isUserActive = false,
    this.isReady = false,
    this.errorMessage,
    this.textTracks,
    this.audioTracks,
    this.webViewController,
  });

  WebPlayerValue copyWith({
    double? currentTime,
    double? duration,
    double? bufferedPercent,
    bool? isPaused,
    bool? isFullScreen,
    bool? isInPictureInPicture,
    bool? isTracking,
    bool? isCover,
    bool? isUserActive,
    bool? isReady,
    String? errorMessage,
    List<VideoTrack>? textTracks,
    List<VideoTrack>? audioTracks,
    InAppWebViewController? webViewController,
  }) {
    return WebPlayerValue(
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      bufferedPercent: bufferedPercent ?? this.bufferedPercent,
      isPaused: isPaused ?? this.isPaused,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isInPictureInPicture: isInPictureInPicture ?? this.isInPictureInPicture,
      isTracking: isTracking ?? this.isTracking,
      isCover: isCover ?? this.isCover,
      isUserActive: isUserActive ?? this.isUserActive,
      isReady: isReady ?? this.isReady,
      errorMessage: errorMessage ?? this.errorMessage,
      audioTracks: audioTracks ?? this.audioTracks,
      textTracks: textTracks ?? this.textTracks,
      webViewController: webViewController ?? this.webViewController,
    );
  }
}
