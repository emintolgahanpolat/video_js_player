import 'dart:convert';

class VideoTrack {
  String? src;
  bool? defaultTrack;
  String? id;
  String? kind;
  String? label;
  String? language;
  String? mode;
  bool? enabled;

  VideoTrack({
    this.src,
    this.defaultTrack,
    this.id,
    this.kind,
    this.label,
    this.language,
    this.mode,
    this.enabled,
  });

  factory VideoTrack.fromJson(Map<String, dynamic> json) => VideoTrack(
        defaultTrack: json['default'] as bool?,
        id: json['id'] as String?,
        kind: json['kind'] as String?,
        label: json['label'] as String?,
        language: json['language'] as String?,
        mode: json['mode'] as String?,
        enabled: json['enabled'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'default': defaultTrack,
        'id': id,
        'kind': kind,
        'label': label,
        'language': language,
        'mode': mode,
        'enabled': enabled,
      };

  static List<VideoTrack>? parseVideoTracks(String jsonString) {
    List<dynamic> jsonList = json.decode(jsonString);

    if (jsonList.isNotEmpty && jsonList.first is List) {
      jsonList = jsonList.first;
    }

    return jsonList
        .map((json) => VideoTrack.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
