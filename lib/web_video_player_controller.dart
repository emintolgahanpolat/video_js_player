import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_js_player/web_video_player_source.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

typedef WebPlayerErrorListerner = void Function(String message);

class WebVideoPlayerController extends ValueNotifier<WebPlayerValue> {
  late WebViewController _webViewController;
  WebViewController get webViewController => _webViewController;

  WebVideoPlayerController()
      : super(WebPlayerValue(0, 0, 0, false, false, false, true)) {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("PlayerError", onMessageReceived: (params) {
        _errorListerner?.call(params.message.toString());
      })
      ..addJavaScriptChannel("PlayerInfo", onMessageReceived: (params) {
        print("Player Info Message : ${params.message}");
        List<String> mData = [
          "0",
          "0",
          "0",
          "false",
          "false",
          "false",
          "false"
        ];
        try {
          mData = (jsonDecode(params.message) as List)
              .map<String>((item) => item.toString())
              .toList();
        } catch (e) {
          print(e);
        }

        value = WebPlayerValue(
            double.tryParse(mData[0]) ?? 0,
            double.tryParse(mData[1]) ?? 0,
            double.tryParse(mData[2]) ?? 0,
            bool.tryParse(mData[3]) ?? false,
            value.isFullScreen,
            bool.tryParse(mData[4]) ?? false,
            bool.tryParse(mData[5]) ?? false);
      })
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false);

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
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
  Future<void> videoJs(WebPlayerSource source) {
    _source = source;
    return webViewController.loadHtmlString("""
  <head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://vjs.zencdn.net/8.12.0/video-js.css" rel="stylesheet" />
    <link href="https://videojs-http-streaming.netlify.app/node_modules/videojs-contrib-quality-levels/dist/videojs-contrib-quality-levels.js">
    <title>Video Oynatıcı</title>
    <style>
        body,
        html {
            margin: 0;
            padding: 0;
          height: 100%;
           overflow: hidden;
         background-color:black;
        }

        .video-js {
            width: 100%;
            height: 100%;   
             background-color:black;
             content: none;
        }
    </style>
  </head>

  <body>
    <video id="videoPlayer" class="video-js" poster="${source.poster}" controls playsinline preload="auto"  >
        <source src="${source.url}" type="application/x-mpegURL" />
      
    </video>
    <script src="https://vjs.zencdn.net/8.12.0/video.min.js"></script>
    <script>
        var player = videojs("videoPlayer", {
            errorDisplay: $kDebugMode,
            autoplay:${source.autoPlay},
            controls: ${source.customControlsBuilder == null},
         
        });
          player.on(['progress','durationchange', 'timeupdate', 'paused','play','enterpictureinpicture', 'leavepictureinpicture'], (event) => {  
          var duration = player.duration(); 
          if(duration === Infinity || isNaN(duration)){
           duration = 0
          }
          var currentTime = player.currentTime()
          if(currentTime === Infinity || isNaN(currentTime)){
           currentTime = 0
          }
          var bufferedPercent = player.bufferedPercent();
          if(bufferedPercent === Infinity || isNaN(bufferedPercent)) {
            bufferedPercent = 0;
          }

          PlayerInfo.postMessage(JSON.stringify([currentTime, duration, bufferedPercent ,player.paused(),player.isInPictureInPicture(), player.liveTracker.isTracking()]));
          
          });
        player.on("error", (event) => {  
           var error = player.error();
          PlayerError.postMessage(error.message);
        });
    </script>
  </body>
""");
  }

  void disposeController() {
    _webViewController.runJavaScript('player.dispose();');
    _webViewController.loadRequest(Uri.parse('about:blank'));
    _webViewController.clearCache();
    _webViewController.reload();
  }

  Future<void> iframe(WebPlayerSource source) {
    _source = source;
    webViewController.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) async {
        if (request.url == "about:blank" || request.url == source.url) {
          return NavigationDecision.navigate;
        }
        return NavigationDecision.prevent;
      },
    ));
    return webViewController.loadHtmlString("""
<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Video Oynatıcı</title>
    <style>
        body,
        html {
            margin: 0;
            padding: 0;
          height: 100%;
           overflow: hidden;
         background-color:black;
        }

        iframe {
            width: 100%;
            height: 100%;
        }
    </style>
</head>

<body>


   <iframe src="${source.url}" frameborder="0" autoplay=${source.autoPlay} allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

</body>
""");
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

  Future<void> seekTo(double timeInSecond) {
    value = value.copyWith(currentTime: timeInSecond);
    return webViewController
        .runJavaScript('player.currentTime($timeInSecond);');
  }

  Future<void> play() {
    return webViewController.runJavaScript('player.play();');
  }

  Future<void> pause() {
    return webViewController.runJavaScript('player.pause();');
  }

  Future<void> requestFullscreen() {
    return webViewController.runJavaScript('player.requestFullscreen();');
  }

  Future<void> exitFullscreen() {
    return webViewController.runJavaScript('player.exitFullscreen();');
  }

  Future<void> requestPictureInPicture() {
    return webViewController.runJavaScript('player.requestPictureInPicture();');
  }

  Future<void> exitPictureInPicture() {
    return webViewController.runJavaScript('player.exitPictureInPicture();');
  }

  Future<bool> isTracking() {
    return webViewController
        .runJavaScriptReturningResult(
            '(function(){return  player.liveTracker.isTracking();})()')
        .then((v) => bool.tryParse(v.toString()) ?? false);
  }

  Future<List<dynamic>> textTracks() {
    return webViewController.runJavaScriptReturningResult('''
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

  Future<List<dynamic>> audioTracks() {
    return webViewController.runJavaScriptReturningResult('''
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

  Future<void> changeTextTrack(String id) {
    return webViewController.runJavaScript('''
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

  Future<void> changeAudioTracks(String id) {
    return webViewController.runJavaScript('''
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
}

class WebPlayerValue {
  double currentTime;
  double duration;
  double bufferedPercent;
  bool isPaused;
  bool isFullScreen;
  bool isInPictureInPicture;
  bool isTracking;
  WebPlayerValue(
    this.currentTime,
    this.duration,
    this.bufferedPercent,
    this.isPaused,
    this.isFullScreen,
    this.isInPictureInPicture,
    this.isTracking,
  );

  WebPlayerValue copyWith({
    double? currentTime,
    double? duration,
    double? bufferedPercent,
    bool? isPaused,
    bool? isFullScreen,
    bool? isInPictureInPicture,
    bool? isTracking,
  }) {
    return WebPlayerValue(
      currentTime ?? this.currentTime,
      duration ?? this.duration,
      bufferedPercent ?? this.bufferedPercent,
      isPaused ?? this.isPaused,
      isFullScreen ?? this.isFullScreen,
      isInPictureInPicture ?? this.isInPictureInPicture,
      isTracking ?? this.isTracking,
    );
  }
}
