import 'package:json_annotation/json_annotation.dart';
import 'package:remote_api/remote_api.dart';

part 'movie_rm.g.dart';

@JsonSerializable(createToJson: false)
class MovieRM {
  final DateTime createdAt;
  final DateTime updatedAt;

  final String objectId;
  final String inboxType;
  final String type;
  final MovieSourceRM source;
  final MovieAudioFileRM audioFile;

  final String title;
  final String url;
  final MoviePostRM post;
  final MovieImageRM image;
  final String text;
  final String audioType;

  static const fromJson = _$MovieRMFromJson;

  MovieRM(
      {required this.createdAt,
      required this.updatedAt,
      required this.objectId,
      required this.inboxType,
      required this.type,
      required this.source,
      required this.audioFile,
      required this.title,
      required this.url,
      required this.post,
      required this.image,
      required this.text,
      required this.audioType});
}

@JsonSerializable(createToJson: false)
class MovieSourceRM {
  final String role;
  final String updatedAt;
  final int wordLevel;
  final String displayName;

  //final Map articleLikes;
  final String objectId;
  final int inviteCount;
  final String username;
  final String createdAt;

//final Map likes;
//   final String className;
//   final bool emailVerified;
  final int practiceType;
  final int blocked;
  final String coverImageUrl;

  // final int hasBoundQQ2;
  // final bool isVip;
//   final bool mobilePhoneVerified;

  static const fromJson = _$MovieSourceRMFromJson;

  MovieSourceRM(
      {required this.role,
      required this.updatedAt,
      required this.wordLevel,
      required this.displayName,
      required this.objectId,
      required this.inviteCount,
      required this.username,
      required this.createdAt,
      required this.practiceType,
      required this.blocked,
      required this.coverImageUrl});
}

@JsonSerializable(createToJson: false)
class MovieAudioFileRM {
  final String url;

  static const fromJson = _$MovieAudioFileRMFromJson;

  MovieAudioFileRM({required this.url});
}

@JsonSerializable(createToJson: false)
class MoviePostRM {
  final DateTime updatedAt;
  final MoviePublishDateRM publishDate;

  final bool isPublished;
  final int pageviews;
  final String objectId;
  final String? videoUrl;
  final String imageUrl;

  final String audioUrl;
  final String text;
  final String title;

  static const fromJson = _$MoviePostRMFromJson;

  MoviePostRM(
      {required this.updatedAt,
        required this.title,
        required this.isPublished,
        required this.publishDate,
      required this.pageviews,
      required this.objectId,
      required this.videoUrl,
      required this.audioUrl,
        required this.imageUrl,
      required this.text});
}

@JsonSerializable(createToJson: false)
class MoviePublishDateRM {
  final DateTime iso;

  MoviePublishDateRM({required this.iso});
  static const fromJson = _$MoviePublishDateRMFromJson;
}

@JsonSerializable(createToJson: false)
class MovieImageRM {
  final String url;

  static const fromJson = _$MovieImageRMFromJson;

  MovieImageRM({required this.url});
}

extension MovieRMtoFeedRM on MovieRM {
  FeedRM toFeedRM() {
    return FeedRM(
        id: objectId,
        createdAt: createdAt,
        updatedAt: post.publishDate.iso,
        source: FeedSourceRM(
            displayName: source.displayName, username: source.username),
        data: FeedDataRM(
            inboxType: inboxType,
            type: type,
            title: post.title,
            url: url,
            post: FeedPostRM(
              isPublished: post.isPublished,
              pageviews: post.pageviews,
              objectId: post.objectId,
              videoUrl: post.videoUrl,
            ),
            image: FeedImageRM(url: post.imageUrl),
            text: text,
            audioType: audioType,
            commentCount: 0));
  }
}
