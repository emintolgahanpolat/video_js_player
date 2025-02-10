import 'package:flutter/material.dart';
import 'package:video_js_player/web_video_player_controller.dart';

class WebPlayerVideoSource {
  final String src;
  final WebPlayerVideoSourceType type;
  WebPlayerVideoSource(this.src, this.type);
}

enum WebPlayerVideoSourceType { mpegURL, mp4, ogg, webm }

extension WebPlayerVideoSourceTypeEx on WebPlayerVideoSourceType {
  String get typeText {
    return switch (this) {
      WebPlayerVideoSourceType.mpegURL => "application/x-mpegURL",
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
  final List<WebPlayerVideoSource>? sources;
  final bool autoPlay;

  // String get source => [...?_sources]
  //     .map((e) => '<source src="${e.src}" type="${e.type.typeText}" />')
  //     .join("\n")
  //     .toString();
  // final List<WebPlayerVideoTrack>? _tracks;
  // String get track => [...?_tracks]
  //     .map((e) =>
  //         '<track kind="${e.kind}" src="${e.src}" srclang="${e.srcLang}" label="${e.label}" />" />')
  //     .join("\n")
  //     .toString();

  WebPlayerSource._({
    this.url,
    this.poster,
    required this.type,
    this.customControlsBuilder,
    this.sources,
    bool? autoPlay,
  }) : autoPlay = autoPlay ?? false;

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

  static WebPlayerSource videoJs(
      {WebPlayerVideoSource? source,
      String? poster,
      bool? autoPlay,
      List<WebPlayerVideoSource>? sources,
      final Widget Function(WebVideoPlayerController controller)?
          customControlsBuilder}) {
    var sources0 = sources ?? [];
    if (source != null) {
      sources0.add(source);
    }
    return WebPlayerSource._(
        poster: poster,
        type: WebPlayerSourceType.videoJs,
        autoPlay: autoPlay,
        sources: sources0,
        customControlsBuilder: customControlsBuilder);
  }
}

enum WebPlayerSourceType { iframe, videoJs }
