import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPlayerValue {
  final InAppWebViewController? webViewController;
  double currentTime;
  double duration;
  double bufferedPercent;
  bool isPaused;
  bool isFullScreen;
  bool isInPictureInPicture;
  bool isTracking;
  WebPlayerValue({
    this.currentTime = 0,
    this.duration = 0,
    this.bufferedPercent = 0,
    this.isPaused = false,
    this.isFullScreen = false,
    this.isInPictureInPicture = false,
    this.isTracking = false,
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
      webViewController: webViewController ?? this.webViewController,
    );
  }
}
