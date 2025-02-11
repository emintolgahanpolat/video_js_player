import 'package:video_js_player/web_video_player_source.dart';

String iframeHtml(WebPlayerSource source) {
  return """
   <iframe src="${source.sources.first.src}" controls= alse frameborder="0" autoplay=${source.autoPlay} allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
""";
}
