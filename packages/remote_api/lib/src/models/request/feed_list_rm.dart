class FeedListRM{
  final int limit;
  final String publisher;
  final int syncText;
  final String? tagId;

  FeedListRM({required this.publisher, required this.tagId,this.limit=10, this.syncText=1});
}