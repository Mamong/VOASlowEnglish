import 'package:json_annotation/json_annotation.dart';

part 'feed_rm.g.dart';

@JsonSerializable(createToJson: false)
class FeedRM{
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeedSourceRM source;
  final FeedDataRM data;

  FeedRM({required this.id, required this.createdAt, required this.updatedAt,required this.source, required this.data});
  static const fromJson = _$FeedRMFromJson;
}

@JsonSerializable(createToJson: false)
class FeedSourceRM{
  final String displayName;
  final String username;

  FeedSourceRM({required this.displayName,
    required this.username});
  static const fromJson = _$FeedSourceRMFromJson;
}

@JsonSerializable(createToJson: false)
class FeedDataRM{
  final String inboxType;
  //syncText,article
  final String type;
  final String title;
  final String? url;
  final FeedPostRM post;
  final FeedImageRM image;
  final String text;
  final String audioType;
  final int commentCount;

  @JsonKey(includeFromJson: true)
  final String? addition;

  FeedDataRM({required this.inboxType,
    required this.type,
    required this.title,
    this.url,
    this.addition,
    required this.post,
    required this.image,
    required this.text,
    required this.audioType,
    required this.commentCount});
  static const fromJson = _$FeedDataRMFromJson;
}

@JsonSerializable(createToJson: false)
class FeedImageRM {
  final String url;

  FeedImageRM({required this.url});
  static const fromJson = _$FeedImageRMFromJson;
}

@JsonSerializable(createToJson: false)
class FeedPostRM {
  final bool isPublished;
  final int pageviews;
  final String objectId;
  final String? videoUrl;

  FeedPostRM({required this.isPublished, required this.pageviews, required this.objectId, this.videoUrl});
  static const fromJson = _$FeedPostRMFromJson;
}