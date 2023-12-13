
import 'package:json_annotation/json_annotation.dart';
part 'publisher_group_rm.g.dart';

@JsonSerializable(createToJson: false)
class PublisherGroupRM{
  final String desc;
  final List<PublisherInfoRM> publisherInfo;

  PublisherGroupRM({required this.desc,
    required this.publisherInfo});
  static const fromJson = _$PublisherGroupRMFromJson;
}

@JsonSerializable(createToJson: false)
class PublisherInfoRM{
  final String publisherName;
  final String description;
  final String name;
  final String icon;
  final bool hasTag;
  final bool? isVideo;
  final List<PublisherTagRM>? tags;
  final int subscribedCount;

  PublisherInfoRM({required this.publisherName,
    required this.description,
    required this.name,
    required this.icon,
    required this.hasTag,
    required this.subscribedCount,
    this.tags,
    this.isVideo
  });
  static const fromJson = _$PublisherInfoRMFromJson;
}

@JsonSerializable(createToJson: false)
class PublisherTagRM {
  final String tagId;
  final String tagName;

  PublisherTagRM({required this.tagId,
    required this.tagName});
  static const fromJson = _$PublisherTagRMFromJson;
}