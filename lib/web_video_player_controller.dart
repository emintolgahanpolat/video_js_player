import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/model/track_type.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:video_js_player/web_video_player_value.dart';

typedef WebPlayerErrorListerner = void Function(String message);

class WebVideoPlayerController extends ValueNotifier<WebPlayerValue> {
  InAppWebViewController? get webViewController => value.webViewController;
  WebVideoPlayerController() : super(WebPlayerValue());
  static WebVideoPlayerController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedWebVideoPlayer>()
        ?.controller;
  }

  WebPlayerSource? _source;
  WebPlayerSource? get source => _source;
  void load(WebPlayerSource source) {
    _source = source;
  }

  void updateValue(WebPlayerValue newValue) => value = newValue;

  void toggleFullScreenMode() {
    var fs = value.isFullScreen;
    updateValue(value.copyWith(isFullScreen: !fs));
    if (!fs) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) async {
    if (webViewController == null) {
      throw "webViewController is null";
    }
    return webViewController?.evaluateJavascript(
        source: source, contentWorld: contentWorld);
  }

  Future<dynamic>? src(WebPlayerSource source) {
    return evaluateJavascript(
        source:
            'player.src({ type: "${source.type}", src: "${source.src}" });');
  }

  Future<dynamic>? seekTo(double timeInSecond) {
    value = value.copyWith(currentTime: timeInSecond);
    return evaluateJavascript(source: 'player.currentTime($timeInSecond);');
  }

  Future<dynamic>? play() {
    return evaluateJavascript(source: 'player.play();');
  }

  Future<void>? pause() {
    return evaluateJavascript(source: 'player.pause();');
  }

  Future<void> requestFullscreen() async {
    if (Platform.isIOS) {
      return evaluateJavascript(source: """
var videoElement = player.el().querySelector('video');
 videoElement.webkitEnterFullscreen();
""");
    } else {
      return evaluateJavascript(source: 'player.requestFullscreen();');
    }
  }

  Future<void> exitFullscreen() async {
    return evaluateJavascript(source: 'player.exitFullscreen();');
  }

  Future<void> requestPictureInPicture() async {
    return evaluateJavascript(source: 'player.requestPictureInPicture();');
  }

  Future<void> exitPictureInPicture() async {
    return evaluateJavascript(source: 'player.exitPictureInPicture();');
  }

  Future<bool> isTracking() async {
    webViewController
        ?.evaluateJavascript(
            source: '(function(){return  player.liveTracker.isTracking();})()')
        .then((v) => bool.tryParse(v.toString()) ?? false);
    return false;
  }

  Future<void>? changeTextTrack(String id) {
    return evaluateJavascript(source: '''
  (function(){

   var tracks = player.textTracks();

    for (var i = 0; i < tracks.length; i++) {
      // Track dilini kontrol et ve görünürlüğünü ayarla
      if (tracks[i].id === "$id") {
        tracks[i].mode = 'showing'; // Bu track'i göster
      } else {
        tracks[i].mode = 'disabled'; // Diğer track'leri gizle
      }
    }

  })();
''');
  }

  Future<void>? changeAudioTracks(String id) {
    return evaluateJavascript(source: '''
  (function(){

   var tracks = player.audioTracks();

    for (var i = 0; i < tracks.length; i++) {
      // Track dilini kontrol et ve görünürlüğünü ayarla
      if (tracks[i].id === "$id") {
        tracks[i].enabled = true; // Bu track'i göster
      } else {
        tracks[i].enabled = false; // Diğer track'leri gizle
      }
    }

  })();
''');
  }

  Future<void>? addRemoteTextTrack(VideoTrack track) {
    return evaluateJavascript(source: '''
  (function(){
// 
   player.addRemoteTextTrack({
    id:'${track.id ?? track.label}',
    kind: '${track.kind}',
    src: '${track.src}',
    srclang: '${track.language}',
    label: '${track.label}',
    }, false);
  })();
''');
  }
}

/// An inherited widget to provide [WebVideoPlayerController] to it's descendants.
class InheritedWebVideoPlayer extends InheritedWidget {
  /// Creates [InheritedWebVideoPlayer]
  const InheritedWebVideoPlayer({
    super.key,
    required this.controller,
    required super.child,
  });

  /// A [WebVideoPlayerController] which controls the player.
  final WebVideoPlayerController controller;

  @override
  bool updateShouldNotify(InheritedWebVideoPlayer oldWidget) {
    return oldWidget.controller.hashCode != controller.hashCode;
  }
}
