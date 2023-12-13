class PublisherGroup{
  final String desc;
  final List<Publisher> publisherInfo;

  PublisherGroup({required this.desc, required this.publisherInfo});
}

class Publisher{
  final String publisherName;
  final String description;
  final String name;
  final String icon;
  final bool hasTag;
  final bool isVideo;

  bool isBooked = false;
  String desc = "";

  final List<PublisherTag>? tags;
  final int subscribedCount;

  Publisher({required this.publisherName, required this.description, required this.name, required this.icon, required this.hasTag, this.tags, required this.subscribedCount, required this.isVideo});
}

class PublisherTag{
  final String tagId;
  final String tagName;

  PublisherTag({required this.tagId, required this.tagName});
}