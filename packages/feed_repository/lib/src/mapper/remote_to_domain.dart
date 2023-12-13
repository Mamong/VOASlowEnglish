import 'package:domain_models/domain_models.dart';
import 'package:remote_api/remote_api.dart';

extension FeedRMtoDomain on FeedRM {
  Feed toDomainModel() {
    return Feed(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        displayName: source.displayName,
        username: source.username,
        type: data.type,
        title: data.title.isNotEmpty ? data.title : data.text,
        url: data.url,
        addition: data.addition,
        videoUrl: data.post.videoUrl,
        image: data.image.url,
        text: data.text,
        pageviews: data.post.pageviews);
  }
}

extension PublisherGroupRMtoDomain on PublisherGroupRM {
  PublisherGroup toDomainModel() {
    return PublisherGroup(
        desc: desc,
        publisherInfo: publisherInfo.map((e) => e.toDomainModel()).toList());
  }
}

extension PublisherInfoRMtoDomain on PublisherInfoRM {
  Publisher toDomainModel() {
    return Publisher(
        publisherName: publisherName,
        description: description,
        name: name,
        icon: icon,
        hasTag: hasTag,
        isVideo: isVideo ?? false,
        subscribedCount: subscribedCount,
        tags: tags?.map((e) => e.toDomainModel()).toList());
  }
}

extension PublisherTagRMtoDomain on PublisherTagRM {
  PublisherTag toDomainModel() {
    return PublisherTag(tagId: tagId, tagName: tagName);
  }
}
