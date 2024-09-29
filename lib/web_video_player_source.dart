import 'package:flutter/material.dart';
import 'package:video_js_player/web_video_player_controller.dart';

class WebPlayerVideoSource {
  final String src;
  final WebPlayerVideoSourceType type;
  WebPlayerVideoSource(this.src, this.type);
}

enum WebPlayerVideoSourceType { mp4, ogg, webm }

extension WebPlayerVideoSourceTypeEx on WebPlayerVideoSourceType {
  String get typeText {
    return switch (this) {
      WebPlayerVideoSourceType.mp4 => "video/mp4",
      WebPlayerVideoSourceType.ogg => "video/ogg",
      WebPlayerVideoSourceType.webm => "video/webm",
    };
  }
}

class WebPlayerVideoTrack {
  String src;
  String srcLang;
  String label;
  String kind;
  WebPlayerVideoTrackType type;
  WebPlayerVideoTrack(this.src, this.srcLang, this.kind, this.label, this.type);
}

enum WebPlayerVideoTrackType {
  subtitles,
  captions,
  descriptions,
  chapters,
  metadata
}

class WebPlayerSource {
  final Widget Function(WebVideoPlayerController controller)?
      customControlsBuilder;
  final String? url;
  final String? poster;
  final WebPlayerSourceType type;
  final List<WebPlayerVideoSource>? _sources;
  final bool autoPlay;
  final String? adTagUrl;
  String get source => [...?_sources]
      .map((e) => '<source src="${e.src}" type="${e.type.typeText}" />')
      .join("\n")
      .toString();
  final List<WebPlayerVideoTrack>? _tracks;
  String get track => [...?_tracks]
      .map((e) =>
          '<track kind="${e.kind}" src="${e.src}" srclang="${e.srcLang}" label="${e.label}" />" />')
      .join("\n")
      .toString();
  WebPlayerSource._({
    this.url,
    this.poster,
    required this.type,
    this.customControlsBuilder,
    this.adTagUrl,
    bool? autoPlay,
    List<WebPlayerVideoSource>? sources,
    List<WebPlayerVideoTrack>? tracks,
  })  : _sources = sources,
        _tracks = tracks,
        autoPlay = autoPlay ?? false;
  static WebPlayerSource withUrl(
    String url, {
    String? poster,
    bool? autoPlay,
  }) {
    return WebPlayerSource._(
        url: url,
        poster: poster,
        type: WebPlayerSourceType.iframe,
        autoPlay: autoPlay,
        customControlsBuilder: null);
  }

  static WebPlayerSource videoJs(String url,
      {String? poster,
      bool? autoPlay,
      String? adTagUrl,
      final Widget Function(WebVideoPlayerController controller)?
          customControlsBuilder}) {
    return WebPlayerSource._(
        url: url,
        poster: poster,
        type: WebPlayerSourceType.videoJs,
        autoPlay: autoPlay,
        adTagUrl: adTagUrl,
        customControlsBuilder: customControlsBuilder);
  }
}

enum WebPlayerSourceType { iframe, videoJs }
