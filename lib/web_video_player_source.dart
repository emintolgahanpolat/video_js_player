import 'package:video_js_player/model/track_type.dart';

enum WebPlayerVideoSourceType { iframe, mpegURL, mp4, ogg, webm }

extension WebPlayerVideoSourceTypeEx on WebPlayerVideoSourceType {
  String get typeText {
    return switch (this) {
      WebPlayerVideoSourceType.iframe => "iframe",
      WebPlayerVideoSourceType.mpegURL => "application/x-mpegURL",
      WebPlayerVideoSourceType.mp4 => "video/mp4",
      WebPlayerVideoSourceType.ogg => "video/ogg",
      WebPlayerVideoSourceType.webm => "video/webm",
    };
  }
}

class WebPlayerSource {
  final String src;
  final String type;
  final String? poster;
  final bool autoPlay;
  final List<VideoTrack>? textTracks;

  WebPlayerSource._({
    this.poster,
    required this.src,
    required this.type,
    this.textTracks,
    bool? autoPlay,
  }) : autoPlay = autoPlay ?? false;

  static WebPlayerSource iframe(
    String url, {
    String? poster,
    bool? autoPlay,
  }) {
    return WebPlayerSource._(
        poster: poster,
        autoPlay: autoPlay,
        src: url,
        type: WebPlayerVideoSourceType.iframe.typeText);
  }

  static WebPlayerSource video(
    String src,
    WebPlayerVideoSourceType type, {
    String? poster,
    bool? autoPlay,
    List<VideoTrack>? textTracks,
  }) {
    return WebPlayerSource._(
      poster: poster,
      autoPlay: autoPlay,
      src: src,
      type: type.typeText,
      textTracks: textTracks,
    );
  }
}
