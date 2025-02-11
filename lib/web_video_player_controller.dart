import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_js_player/web_video_player_source.dart';
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

  void setError(String error) {
    _errorListerner?.call(error);
  }

  WebPlayerErrorListerner? _errorListerner;
  void setErrorListener(WebPlayerErrorListerner listener) {
    _errorListerner = listener;
  }

  WebPlayerSource? _source;
  WebPlayerSource? get source => _source;
  void load(WebPlayerSource source) {
    _source = source;
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

  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) async {
    if (webViewController == null) {
      throw "webViewController is null";
    }
    return webViewController?.evaluateJavascript(
        source: source, contentWorld: contentWorld);
  }

  Future<dynamic>? src(List<WebPlayerVideoSource> source) {
    return evaluateJavascript(
        source:
            'player.src({ type: "${source.first.type}", src: "${source.first.src}" });');
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
    return evaluateJavascript(source: 'player.requestFullscreen();');
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

  Future<List<dynamic>> textTracks() async {
    return evaluateJavascript(source: '''
 (function() {
        var textTracks = player.textTracks();
        var arrayList = [];

        Array.from(textTracks).forEach(function(track) {
            if (track.kind === 'subtitles' || track.kind === 'captions') {
              var trackObj = {
                            default: track.default || false,
                            id: track.id || '',
                            kind: track.kind,
                            label: track.label,
                            language: track.language,
                            mode: track.mode
                        };
                   arrayList.push(trackObj);
            }
        });

return JSON.stringify(arrayList);

    })();

''').then((v) {
      return jsonDecode(v.toString());
    });
  }

  Future<List<dynamic>> audioTracks() async {
    return evaluateJavascript(source: '''
 (function() {
        var audioTracks = player.audioTracks();
         var arrayList = [];
        Array.from(audioTracks).forEach(function(track) {
         var trackObj = {
                            default: track.default || false,
                            enabled: track.enabled || false,
                            id: track.id || '',
                            kind: track.kind,
                            label: track.label,
                            language: track.language,
                            mode: track.mode
                        };
             arrayList.push(trackObj);
        });

return JSON.stringify(arrayList);

    })();

''').then((v) {
      return jsonDecode(v.toString());
    });
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

  Future<void>? addRemoteTextTrack({
    required String kind,
    required String src,
    required String srclang,
    required String label,
    String? id,
  }) {
    return evaluateJavascript(source: '''
  (function(){
// 
   player.addRemoteTextTrack({
    id:'${id ?? label}',
    kind: '$kind',
    src: '$src',
    srclang: '$srclang',
    label: '$label',
    }, false);
  })();
''');
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
