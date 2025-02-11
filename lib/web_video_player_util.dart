import 'package:video_js_player/web_video_player_source.dart';

String videoJsHtml() {
  return """
<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <link href="https://vjs.zencdn.net/8.12.0/video-js.css" rel="stylesheet" />
    <title>Video Oynatıcı</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" />
    <link rel="stylesheet" href="mobile-ui.css">

</head>

<body>
    <video id="videoPlayer" class="video-js" controls playsinline preload="auto">




    </video>
    <script src="https://vjs.zencdn.net/8.12.0/video.min.js"></script>
    <script src="mobile-ui.js"></script>
    <script>
        var player = videojs("videoPlayer", {
            errorDisplay: true,
            autoplay: false,
            controls: false,
            controlBar: {
                playToggle: true,
                volumePanel: false,
                fullscreenToggle: true,
                subsCapsButton: true,
                audioTrackButton: true,
                pictureInPictureToggle: true,
            },

        });
        if (window.flutter_inappwebview === undefined) {
            player.src({
                src: "https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8",
                type: "application/x-mpegURL"
            });
            player.controls(true);
        }
        player.mobileUiPlugin();

        player.on(["useractive", "userinactive"], (event) => {
            _callHandler("useractive", event.type == "useractive");
        });
        player.on("progress", (event) => {

            var bufferedPercent = player.bufferedPercent();
            if (bufferedPercent === Infinity || isNaN(bufferedPercent)) {
                bufferedPercent = 0;
            }
            _callHandler("bufferedPercent", bufferedPercent);
        });
        player.on("timeupdate", (event) => {
            var currentTime = player.currentTime()
            if (currentTime === Infinity || isNaN(currentTime)) {
                currentTime = 0
            }

            _callHandler("currentTime", currentTime);
        });
        player.on("volumechange", (event) => {
            _callHandler("volumechange", player.muted() ? 0 : player.volume());
        });
        player.on("muted", (event) => {
            _callHandler("muted", player.muted());
        });
        player.on("ratechange", (event) => {
            _callHandler("ratechange", player.playbackRate());
        });
        player.on("seeking", (event) => {
            _callHandler("seeking", player.seeking());
        });
        player.on("seeked", (event) => {
            _callHandler("seeked", true);
        });
        player.on("ready", (event) => {
            _callHandler("ready", true);

        });
        player.on('loadedmetadata', function () {
            var audioTracks = player.audioTracks();
            var audioTracksList = [];
            for (var i = 0; i < audioTracks.length; i++) {
                var track = audioTracks[i];
                var trackObj = {
                    default: track.default || false,
                    enabled: track.enabled || false,
                    id: track.id || '',
                    kind: track.kind,
                    label: track.label,
                    language: track.language,
                    mode: track.mode
                };
                audioTracksList.push(trackObj);
            }
            _callHandler("audioTracks", audioTracksList);

            var textTracks = player.textTracks();
            var textTracksList = [];

            Array.from(textTracks).forEach(function (track) {
                if (track.kind === 'subtitles' || track.kind === 'captions') {
                    var trackObj = {
                        default: track.default || false,
                        id: track.id || '',
                        kind: track.kind,
                        label: track.label,
                        language: track.language,
                        mode: track.mode
                    };
                    textTracksList.push(trackObj);
                }
            });

            _callHandler("textTracks", textTracksList);
        });
        player.audioTracks().on("change", (event) => {
            var audioTracks = player.audioTracks();
            var audioTracksList = [];
            for (var i = 0; i < audioTracks.length; i++) {
                var track = audioTracks[i];
                var trackObj = {
                    default: track.default || false,
                    enabled: track.enabled || false,
                    id: track.id || '',
                    kind: track.kind,
                    label: track.label,
                    language: track.language,
                    mode: track.mode
                };
                audioTracksList.push(trackObj);
            }
            _callHandler("audioTracks", audioTracksList);
        });
        player.textTracks().on("change", (event) => {

            var textTracks = player.textTracks();
            var textTracksList = [];

            Array.from(textTracks).forEach(function (track) {
                if (track.kind === 'subtitles' || track.kind === 'captions') {
                    var trackObj = {
                        default: track.default || false,
                        id: track.id || '',
                        kind: track.kind,
                        label: track.label,
                        language: track.language,
                        mode: track.mode
                    };
                    textTracksList.push(trackObj);
                }
            });

            _callHandler("textTracks", textTracksList);
        });
        player.on("fullscreenchange", (event) => {
            _callHandler("fullscreenchange", player.isFullscreen());
        });
        player.on("durationchange", (event) => {
            var duration = player.duration();
            if (duration === Infinity || isNaN(duration)) {
                duration = 0
            }
            _callHandler("durationchange", duration);
            _callHandler("isTracking", player.liveTracker.isTracking());
        });
        player.on(["play", "pause"], (event) => {
            _callHandler("pause", player.paused());
        });
        player.on(["enterpictureinpicture", "leavepictureinpicture"], (event) => {
            _callHandler("enterpictureinpicture", player.isInPictureInPicture());
        });
        player.on("ended", (event) => {
            _callHandler("ended", player.ended());
        });
        player.on("error", (event) => {
            var error = player.error();
            _callHandler("error", {
                code: error.code,
                message: error.message
            });
        });
        function _callHandler(method, args) {

            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler(method, args);
            } else {
                console.log(method, args);
            }

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


   <iframe src="${source.sources.first.src}" controls= alse frameborder="0" autoplay=${source.autoPlay} allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

</body>
""";
}
