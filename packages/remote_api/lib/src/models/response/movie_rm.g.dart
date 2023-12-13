// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieRM _$MovieRMFromJson(Map<String, dynamic> json) => MovieRM(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      objectId: json['objectId'] as String,
      inboxType: json['inboxType'] as String,
      type: json['type'] as String,
      source: MovieSourceRM.fromJson(json['source'] as Map<String, dynamic>),
      audioFile:
          MovieAudioFileRM.fromJson(json['audioFile'] as Map<String, dynamic>),
      title: json['title'] as String,
      url: json['url'] as String,
      post: MoviePostRM.fromJson(json['post'] as Map<String, dynamic>),
      image: MovieImageRM.fromJson(json['image'] as Map<String, dynamic>),
      text: json['text'] as String,
      audioType: json['audioType'] as String,
    );

MovieSourceRM _$MovieSourceRMFromJson(Map<String, dynamic> json) =>
    MovieSourceRM(
      role: json['role'] as String,
      updatedAt: json['updatedAt'] as String,
      wordLevel: json['wordLevel'] as int,
      displayName: json['displayName'] as String,
      objectId: json['objectId'] as String,
      inviteCount: json['inviteCount'] as int,
      username: json['username'] as String,
      createdAt: json['createdAt'] as String,
      practiceType: json['practiceType'] as int,
      blocked: json['blocked'] as int,
      coverImageUrl: json['coverImageUrl'] as String,
    );

MovieAudioFileRM _$MovieAudioFileRMFromJson(Map<String, dynamic> json) =>
    MovieAudioFileRM(
      url: json['url'] as String,
    );

MoviePostRM _$MoviePostRMFromJson(Map<String, dynamic> json) => MoviePostRM(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      isPublished: json['isPublished'] as bool,
      publishDate: MoviePublishDateRM.fromJson(
          json['publishDate'] as Map<String, dynamic>),
      pageviews: json['pageviews'] as int,
      objectId: json['objectId'] as String,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      text: json['text'] as String,
    );

MoviePublishDateRM _$MoviePublishDateRMFromJson(Map<String, dynamic> json) =>
    MoviePublishDateRM(
      iso: DateTime.parse(json['iso'] as String),
    );

MovieImageRM _$MovieImageRMFromJson(Map<String, dynamic> json) => MovieImageRM(
      url: json['url'] as String,
    );
