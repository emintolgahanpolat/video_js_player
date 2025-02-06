import 'package:flutter/foundation.dart';
import 'package:video_js_player/web_video_player_source.dart';

String videoJsHtml(WebPlayerSource source) {
  return """
  <head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes">
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

          window.flutter_inappwebview.callHandler('PlayerInfo',currentTime, duration, bufferedPercent ,player.paused(),player.isInPictureInPicture(), player.liveTracker.isTracking());
          
          });
        player.on("error", (event) => {  
           var error = player.error();
          PlayerError.postMessage(error.message);
        });

        function pause() {
                        player.pause();
                          window.flutter_inappwebview.callHandler('TestInfo',"deneme");
          
                        return '';
                    }

       
    </script>
  </body>
""";
}

String iframeHtml(WebPlayerSource source) {
  return """
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
""";
}
