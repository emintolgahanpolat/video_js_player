Web Video Player for Flutter

<p>    
<a href="https://img.shields.io/badge/License-MIT-green"><img     
align="center" src="https://img.shields.io/badge/License-MIT-green" alt="MIT License"></a>         
<a href="https://pub.dev/packages/video_js_player"><img     
align="center" src="https://img.shields.io/pub/v/video_js_player.svg?" alt="pub version"></a>      
<a href="https://www.buymeacoffee.com/emintpolat" target="_blank"><img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>    
<p>  

A Flutter package that provides a web-based video player using Video.js and flutter_inappwebview. This package allows you to integrate a customizable video player in your Flutter application with features like full-screen mode, picture-in-picture, track selection, and more.

🚀 Features

- Play videos from various sources using Video.js

- Full-screen and Picture-in-Picture (PiP) support

- Seek, play, and pause controls

- Change text and audio tracks dynamically

- Add remote text tracks (subtitles)

- Works on Android, iOS, and Web

📦 Installation

Add the package to your pubspec.yaml:
```
dependencies:
  web_video_player: latest_version
```
Then, run:
```
flutter pub get
```

🔧 Usage
```
1️⃣ Import the package:

import 'package:web_video_player/web_video_player.dart';

2️⃣ Initialize the Controller:

final _controller = WebVideoPlayerController();

3️⃣ Embed the Player:

WebVideoPlayer(
  controller: _controller,
  source: WebPlayerSource(
    src: "https://your-video-url.mp4",
    type: "video/mp4",
  ),
)
```
🎛 API & Controls

|Method|Description|
|-|-|
|play()|Plays the video|
|pause()|Pauses the video|
|seekTo(seconds)|Seeks to a specific time|
|toggleFullScreenMode()|Toggles full-screen mode|
|requestPictureInPicture()|Enables Picture-in-Picture mode|
|changeTextTrack(id)|Changes the subtitle track|
|changeAudioTracks(id)|Changes the audio track|
|addRemoteTextTrack({...})|Adds external subtitles|

🖥️ Platform Support

|Platform|Support|
|-|-|
|✅ Android|✔️|
|✅ iOS|✔️|
|✅ Web|✔️|

💡 Notes

This package uses flutter_inappwebview to embed Video.js in a WebView.

📜 License

This project is licensed under the MIT License.

📬 Contact & Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request. 🚀

