//普通风格
class UrlBuilder {
  static const String _baseUrl = 'http://engcorner.cn';
  static const String getPublisherInfo = '$_baseUrl/api/v2/publisherInfo';
  static const String getFeedList = '$_baseUrl/api/v2/feed';
  static const String getMPublisherList = '$_baseUrl/feed/mpublisher';
  static const String getMFeedList = '$_baseUrl/feed';


  static const String getDailyWordList = 'https://lcapi.engcorner.cn/1.1/classes/DailyWord';
  static const String getCommentList = 'https://lcapi.engcorner.cn/1.1/classes/Comment';
  static const String getMovieList = 'https://lcapi.engcorner.cn/1.1/classes/_Status';

}