// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedRM _$FeedRMFromJson(Map<String, dynamic> json) => FeedRM(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      source: FeedSourceRM.fromJson(json['source'] as Map<String, dynamic>),
      data: FeedDataRM.fromJson(json['data'] as Map<String, dynamic>),
    );

FeedSourceRM _$FeedSourceRMFromJson(Map<String, dynamic> json) => FeedSourceRM(
      displayName: json['displayName'] as String,
      username: json['username'] as String,
    );

FeedDataRM _$FeedDataRMFromJson(Map<String, dynamic> json) => FeedDataRM(
      inboxType: json['inboxType'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      url: json['url'] as String?,
      post: FeedPostRM.fromJson(json['post'] as Map<String, dynamic>),
      image: FeedImageRM.fromJson(json['image'] as Map<String, dynamic>),
      text: json['text'] as String,
      audioType: json['audioType'] as String,
      commentCount: json['commentCount'] as int,
    );

FeedImageRM _$FeedImageRMFromJson(Map<String, dynamic> json) => FeedImageRM(
      url: json['url'] as String,
    );

FeedPostRM _$FeedPostRMFromJson(Map<String, dynamic> json) => FeedPostRM(
      isPublished: json['isPublished'] as bool,
      pageviews: json['pageviews'] as int,
      objectId: json['objectId'] as String,
      videoUrl: json['videoUrl'] as String?,
    );
