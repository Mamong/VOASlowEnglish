import 'dart:convert';

class Feed {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String displayName;
  final String username;

  final String type;

  final String title;
  final String? addition;

  final String? url;
  final String? videoUrl;

  String? localPath;

  final String image;

  final String text;

  final int pageviews;

  Feed(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.displayName,
      required this.username,
      required this.title,
      required this.type,
      this.url,
      this.videoUrl,
      required this.image,
      required this.text,
      required this.pageviews,
      this.localPath,
      this.addition});

  List<Map<String, String>>? _captions;

  List<Map<String, String>> get captions {
    if (_captions == null) {
      if (text.startsWith("[")) {
        List segments = json.decode(text);
        _captions = segments.map((e){
          //daily word is double format
          if(e["start"] is! String){
            e["start"] = "00:00:${e["start"]}";
            e["end"] = "00:00:${e["end"]}";
          }
          return Map<String,String>.from(e);
        }).toList();
      } else {
        List<String> segments = text.split("\r\n");
        _captions = segments
            .map((e) => Map<String, String>.from(json.decode(e)))
            .toList();
      }
    }
    return _captions!;
  }
}

/// convert 00:00:00.00 to Duration
/// 00:00:00,000,00:00:0.0
extension StringConvert on String {
  String removeZeroPadding() {
    if (length > 1 && startsWith('0')) {
      return substring(1).removeZeroPadding();
    }
    return this;
  }

  Duration toDuration() {
    String string = replaceAll(",", ".");
    string = string.replaceAll(".", ":");

    List<String> segments =
        string.split(":").take(3).map((e) => e.removeZeroPadding()).toList();
    String milliseconds = string.split(":").last;
    if (milliseconds.length < 3) {
      milliseconds = milliseconds.padRight(3, '0').removeZeroPadding();
    }
    Duration duration = Duration(
      hours: int.parse(segments[0]),
      minutes: int.parse(segments[1]),
      seconds: int.parse(segments[2]),
      milliseconds: int.parse(milliseconds),
    );
    return duration;
  }
}
