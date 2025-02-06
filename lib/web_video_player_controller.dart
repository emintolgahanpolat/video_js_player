import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:video_js_player/web_video_player_util.dart';
import 'package:video_js_player/web_video_player_value.dart';

typedef WebPlayerErrorListerner = void Function(String message);

class WebVideoPlayerController extends ValueNotifier<WebPlayerValue> {
  InAppWebViewController? get webViewController => value.webViewController;
  WebVideoPlayerController() : super(WebPlayerValue());
  static WebVideoPlayerController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedYoutubePlayer>()
        ?.controller;
  }

  WebPlayerErrorListerner? _errorListerner;
  void setErrorListener(WebPlayerErrorListerner listener) {
    _errorListerner = listener;
  }

  Future<void> load(WebPlayerSource source) {
    switch (source.type) {
      case WebPlayerSourceType.videoJs:
        return videoJs(source);
      default:
        return iframe(source);
    }
  }

  WebPlayerSource? _source;
  WebPlayerSource? get source => _source;
  Future<void> videoJs(WebPlayerSource source) async {
    _source = source;
    return webViewController?.loadData(data: videoJsHtml(source));
  }

  @override
  void dispose() {
    value.webViewController?.goBack();
    value.webViewController?.dispose();
    super.dispose();
  }

  Future<void> iframe(WebPlayerSource source) async {
    _source = source;

    return webViewController?.loadData(data: iframeHtml(source));
  }

  void updateValue(WebPlayerValue newValue) => value = newValue;
  void toggleFullScreenMode() {
    value.isFullScreen = !value.isFullScreen;
    if (value.isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<dynamic>? seekTo(double timeInSecond) {
    value = value.copyWith(currentTime: timeInSecond);
    return webViewController?.evaluateJavascript(
        source: 'player.currentTime($timeInSecond);');
  }

  Future<dynamic>? play() {
    return webViewController?.evaluateJavascript(source: 'player.play();');
  }

  Future<void>? pause() {
    if (value.webViewController != null) {
      return webViewController?.evaluateJavascript(source: 'pause()');
    } else {
      print("Error : WebViewController is null");
    }
    return webViewController?.evaluateJavascript(source: 'pause()');
  }

  Future<void> requestFullscreen() async {
    return webViewController?.evaluateJavascript(
        source: 'player.requestFullscreen();');
  }

  Future<void> exitFullscreen() async {
    return webViewController?.evaluateJavascript(
        source: 'player.exitFullscreen();');
  }

  Future<void> requestPictureInPicture() async {
    return webViewController?.evaluateJavascript(
        source: 'player.requestPictureInPicture();');
  }

  Future<void> exitPictureInPicture() async {
    return webViewController?.evaluateJavascript(
        source: 'player.exitPictureInPicture();');
  }

  Future<bool> isTracking() async {
    webViewController
        ?.evaluateJavascript(
            source: '(function(){return  player.liveTracker.isTracking();})()')
        .then((v) => bool.tryParse(v.toString()) ?? false);
    return false;
  }

  Future<List<dynamic>> textTracks() {
//     return webViewController?.evaluateJavascript(source: '''
//  (function() {
//         var textTracks = player.textTracks();
//         var arrayList = [];

//         Array.from(textTracks).forEach(function(track) {
//             if (track.kind === 'subtitles' || track.kind === 'captions') {
//               var trackObj = {
//                             default: track.default || false,
//                             id: track.id || '',
//                             kind: track.kind,
//                             label: track.label,
//                             language: track.language,
//                             mode: track.mode
//                         };
//                    arrayList.push(trackObj);
//             }
//         });

// return JSON.stringify(arrayList);

//     })();

// ''').then((v) {
//       return jsonDecode(v.toString());
//     });
    return Future.value([]);
  }

  Future<List<dynamic>> audioTracks() {
//     return webViewController?.evaluateJavascript(source: '''
//  (function() {
//         var audioTracks = player.audioTracks();
//          var arrayList = [];
//         Array.from(audioTracks).forEach(function(track) {
//          var trackObj = {
//                             default: track.default || false,
//                             enabled: track.enabled || false,
//                             id: track.id || '',
//                             kind: track.kind,
//                             label: track.label,
//                             language: track.language,
//                             mode: track.mode
//                         };
//              arrayList.push(trackObj);
//         });

// return JSON.stringify(arrayList);

//     })();

// ''').then((v) {
//       return jsonDecode(v.toString());
//     });
    return Future.value([]);
  }

  Future<void> changeTextTrack(String id) {
//     return webViewController?.evaluateJavascript(source: '''
//   (function(){

//    var tracks = player.textTracks();

//     for (var i = 0; i < tracks.length; i++) {
//       // Track dilini kontrol et ve görünürlüğünü ayarla
//       if (tracks[i].id === "$id") {
//         tracks[i].mode = 'showing'; // Bu track'i göster
//       } else {
//         tracks[i].mode = 'disabled'; // Diğer track'leri gizle
//       }
//     }

//   })();
// ''');
    return Future.value();
  }

  Future<void> changeAudioTracks(String id) {
//     return webViewController?.evaluateJavascript(source: '''
//   (function(){

//    var tracks = player.audioTracks();

//     for (var i = 0; i < tracks.length; i++) {
//       // Track dilini kontrol et ve görünürlüğünü ayarla
//       if (tracks[i].id === "$id") {
//         tracks[i].enabled = true; // Bu track'i göster
//       } else {
//         tracks[i].enabled = false; // Diğer track'leri gizle
//       }
//     }

//   })();
// ''');
    return Future.value();
  }

  Future<void> addRemoteTextTrack({
    required String kind,
    required String src,
    required String srclang,
    required String label,
    String? id,
  }) {
//     return webViewController?.evaluateJavascript(source: '''
//   (function(){

//    player.addRemoteTextTrack({
//     id:'${id ?? label}',
//     kind: '$kind',
//     src: '$src',
//     srclang: '$srclang',
//     label: '$label',
//     }, false);
//   })();
// ''');
    return Future.value();
  }
}

/// An inherited widget to provide [WebVideoPlayerController] to it's descendants.
class InheritedYoutubePlayer extends InheritedWidget {
  /// Creates [InheritedYoutubePlayer]
  const InheritedYoutubePlayer({
    super.key,
    required this.controller,
    required super.child,
  });

  /// A [WebVideoPlayerController] which controls the player.
  final WebVideoPlayerController controller;

  @override
  bool updateShouldNotify(InheritedYoutubePlayer oldWidget) {
    return oldWidget.controller.hashCode != controller.hashCode;
  }
}
