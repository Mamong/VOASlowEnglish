import 'package:json_annotation/json_annotation.dart';

import '../../../remote_api.dart';

part 'daily_word_rm.g.dart';

@JsonSerializable(createToJson: false)
class DailyWordRM{
  final String word;
  final String definition;
  final WordSnippetRM snippet;
  final DateTime createdAt;
  final DateTime updatedAt;
  //final String publishDate;
  final String objectId;

  DailyWordRM({required this.word, required this.definition, required this.snippet, required this.createdAt, required this.updatedAt, required this.objectId});

  static const fromJson = _$DailyWordRMFromJson;
}

@JsonSerializable(createToJson: false)
class WordSnippetRM{
  // final String languageKnowledge;
  // final List<String> votes;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String audioUrl;
  final String content;
  final String objectId;
  final List<String> words;
  final int dubbingCount;
  final String snippetId;
  // final String className;
  final String imageUrl;
  final int level;
  final String author;
  final String movieName;
  final String videoUrl;
  //final String __type;
  final int videoStart;
  // final String movieInfo;

  WordSnippetRM({required this.updatedAt, required this.audioUrl, required this.content, required this.objectId, required this.words, required this.dubbingCount, required this.snippetId, required this.createdAt, required this.imageUrl, required this.level, required this.author, required this.movieName, required this.videoUrl, required this.videoStart});
  static const fromJson = _$WordSnippetRMFromJson;

}


extension DailyWordRMtoFeedRM on DailyWordRM {
  FeedRM toFeedRM() {
    return FeedRM(
        id: objectId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        source: FeedSourceRM(
            displayName: "", username: ""),
        data: FeedDataRM(
            inboxType: "inboxType",
            type: "type",
            title: word,
            url: snippet.audioUrl,
            addition: definition,
            post: FeedPostRM(
              isPublished: true,
              pageviews: snippet.dubbingCount,
              objectId: objectId,
              videoUrl: snippet.videoUrl,
            ),
            image: FeedImageRM(url: snippet.imageUrl),
            text: snippet.content,
            audioType: "audioType",
            commentCount: 0));
  }
}
