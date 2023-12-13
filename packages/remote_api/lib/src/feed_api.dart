import 'dart:convert';

import 'package:net/net.dart';
import 'package:remote_api/src/models/response/feed_rm.dart';
import 'package:remote_api/src/url_builder.dart';
import 'models/response/daily_word_rm.dart';

import 'models/response/movie_rm.dart';
import 'models/response/publisher_group_rm.dart';

//http://engcorner.cn/api/v2/publisherInfo?app=slow if none match,6minenglish8
//http://engcorner.cn/api/v2/feed?&limit=10&publisher=voaspecial&syncText=1&tagId=60d06011a06dc908f02665be
//全部电影分类http://engcorner.cn/feed/mpublisher?&limit=50
//明星访谈 http://engcorner.cn/feed?&limit=100&s=Interview
//TED演讲标签 http://engcorner.cn/api/v2/publishertag?&publisher=Tedspeech
// http://engcorner.cn/api/v2/feed?&limit=10&publisher=Tedspeech&syncText=1
//电影https://lcapi.engcorner.cn/1.1/classes/_Status?include=post%2Csource&where=%7B%22post%22%3A%7B%22%24inQuery%22%3A%7B%22where%22%3A%7B%22%24and%22%3A%5B%7B%22type%22%3A%22nMovie%22%7D%5D%2C%22publishDate%22%3A%7B%22%24lt%22%3A%7B%22__type%22%3A%22Date%22%2C%22iso%22%3A%222023-11-19T11%3A45%3A56.062Z%22%7D%7D%7D%2C%22className%22%3A%22Post%22%2C%22order%22%3A%22-publishDate%2C-updatedAt%22%2C%22limit%22%3A12%7D%7D%7D
//每日一词 https://lcapi.engcorner.cn/1.1/classes/DailyWord?include=snippet&limit=7&order=-publishDate%2C-updatedAt&where=%7B%22publishDate%22%3A%7B%22%24lt%22%3A%7B%22__type%22%3A%22Date%22%2C%22iso%22%3A%222023-11-25T09%3A03%3A26.641Z%22%7D%7D%7D

const String x_lc_id = "";
const String x_lc_sign = "";

class FeedApi {
  late NetAdapter adapter;

  FeedApi() {
    adapter = DioAdapter();
  }

  //app可选参数：6minenglish8,slow
  Future<List<PublisherGroupRM>> getPublisherInfo(
      {String? app = "slow"}) async {
    const url = UrlBuilder.getPublisherInfo;
    final data = await adapter
        .request(Method.get, url, parameters: {"app": app}) as List<dynamic>;
    final jsonObject = data.cast<Map<String, dynamic>>();
    final list = jsonObject.map((e) => PublisherGroupRM.fromJson(e)).toList();
    return list;
  }

  Future<List<PublisherGroupRM>> getMPublisherInfo(
      {int limit = 50, int pageNum = 0}) async {
    const url = UrlBuilder.getMPublisherList;
    final data = await adapter.request(Method.get, url, parameters: {
      "limit": limit,
      "skip": pageNum * limit,
    }) as List<dynamic>;
    final jsonObject = data.cast<Map<String, dynamic>>();
    final list = jsonObject.map((e) => PublisherGroupRM.fromJson(e)).toList();
    return list;
  }

  Future<List<FeedRM>> getFeedListPage(
      {int limit = 10,
      int pageNum = 0,
      required String publisher,
      int syncText = 1,
      String? tagId}) async {
    const url = UrlBuilder.getFeedList;
    final data = await adapter.request(Method.get, url, parameters: {
      "limit": limit,
      "skip": pageNum * limit,
      "publisher": publisher,
      "syncText": syncText,
      "tagId": tagId
    }) as List<dynamic>;
    final jsonObject = data.cast<Map<String, dynamic>>();
    final list = jsonObject.map((e) => FeedRM.fromJson(e)).toList();
    return list;
  }

  //s=Sciencepromotion
  Future<List<FeedRM>> getMFeedListPage(
      {int limit = 100, int pageNum = 0, required String publisher}) async {
    const url = UrlBuilder.getMFeedList;
    final data = await adapter.request(Method.get, url, parameters: {
      "limit": limit,
      "skip": pageNum * limit,
      "s": publisher,
    }) as List<dynamic>;
    final jsonObject = data.cast<Map<String, dynamic>>();
    final list = jsonObject.map((e) => FeedRM.fromJson(e)).toList();
    return list;
  }

  //每日一词：https://lcapi.engcorner.cn/1.1/classes/DailyWord
  Future<List<FeedRM>> getDailyWordListPage(
      {int limit = 10, DateTime? date}) async {
    const url = UrlBuilder.getDailyWordList;
    date ??= DateTime.now();
    Map<String, dynamic> where = {
      "publishDate": {
        "\$lt": {"__type": "Date", "iso": date.toUtc().toIso8601String()}
      }
    };
    final data = await adapter.request(Method.get, url, parameters: {
      "limit": limit,
      "order": "-publishDate,-updatedAt",
      "include": "snippet",
      "where": json.encode(where),
    }, header: {
      "x-lc-id": x_lc_id,
      "x-lc-prod": 1,
      "x-lc-sign": x_lc_sign
    }) as Map<String, dynamic>;
    //code:401 error:Unauthorized.
    String? error = data["error"];
    if (error == null) {
      List results = data["results"];
      final jsonObject = results.cast<Map<String, dynamic>>();
      final list = jsonObject.map((e) => DailyWordRM.fromJson(e).toFeedRM()).toList();
      return list;
    } else {
      throw Exception(error);
    }
  }

  //美文等评论
  Future<List<FeedRM>> getCommentListPage(
      {int limit = 60, required String postId}) async {
    const url = UrlBuilder.getDailyWordList;
    Map<String, dynamic> where = {
        "\$and": [{"postObjectId": postId}]
    };
    final data = await adapter.request(Method.get, url, parameters: {
      "limit": limit,
      "order": "-createdAt",
      "include": "likes,replyTo,source,toComment",
      "where": where,
    }) as List<dynamic>;
    final jsonObject = data.cast<Map<String, dynamic>>();
    final list = jsonObject.map((e) => FeedRM.fromJson(e)).toList();
    return list;
  }

  //电影
  Future<List<FeedRM>> getMovieListPage({int limit = 12, DateTime? date}) async {
    date ??= DateTime.now();

    const url = UrlBuilder.getMovieList;
    Map<String, dynamic> where = {
      "post": {
        "\$inQuery": {
          "where": {
            "\$and": [
              {"type": "nMovie"}
            ],
            "publishDate": {
              "\$lt": {"__type": "Date", "iso": date.toUtc().toIso8601String()}
            }
          },
          "className": "Post",
          "order": "-publishDate,-updatedAt",
          "limit": limit
        }
      }
    };

    final data = await adapter.request(Method.get, url, parameters: {
      "include": "post,source",
      "where": json.encode(where),
    }, header: {
      "x-lc-id": x_lc_id,
      "x-lc-prod": 1,
      "x-lc-sign": x_lc_sign
    }) as Map<String, dynamic>;
    String? error = data["error"];
    if (error == null) {
      List results = data["results"];
      final jsonObject = results.cast<Map<String, dynamic>>();
      final list = jsonObject.map((e) => MovieRM.fromJson(e).toFeedRM()).toList();
      list.sort((feed1,feed2){
        return feed2.updatedAt.compareTo(feed1.updatedAt);
      });
      return list;
    } else {
      throw Exception(error);
    }
  }

  Future<bool> downloadFeedFile(String url, String destination,
      void Function(int received, int total) progressCallback) async {
    return adapter.download(url, destination,
        progressCallback: progressCallback);
  }
}
