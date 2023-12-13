// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher_group_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublisherGroupRM _$PublisherGroupRMFromJson(Map<String, dynamic> json) =>
    PublisherGroupRM(
      desc: json['desc'] as String,
      publisherInfo: (json['publisherInfo'] as List<dynamic>)
          .map((e) => PublisherInfoRM.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

PublisherInfoRM _$PublisherInfoRMFromJson(Map<String, dynamic> json) =>
    PublisherInfoRM(
      publisherName: json['publisherName'] as String,
      description: json['description'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      hasTag: json['hasTag'] as bool,
      subscribedCount: json['subscribedCount'] as int,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => PublisherTagRM.fromJson(e as Map<String, dynamic>))
          .toList(),
      isVideo: json['isVideo'] as bool?,
    );

PublisherTagRM _$PublisherTagRMFromJson(Map<String, dynamic> json) =>
    PublisherTagRM(
      tagId: json['tagId'] as String,
      tagName: json['tagName'] as String,
    );
