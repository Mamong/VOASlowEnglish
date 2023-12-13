import 'dart:io';

import 'package:domain_models/domain_models.dart';
import 'package:feed_repository/src/path_utils.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:meta/meta.dart';
import 'package:remote_api/remote_api.dart';
import './mapper/mappers.dart';
import 'feed_local_storage.dart';

class FeedRepository {
  FeedRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting FeedLocalStorage? localStorage,
  }) : _localStorage = localStorage ??
            FeedLocalStorage(
              noSqlStorage: keyValueStorage,
            );

  final FeedApi remoteApi;
  final FeedLocalStorage _localStorage;

  //内存缓存,方便读取详情
  Map<String, Feed> _cache = {};
  List<PublisherGroup>? groups;

  Future<List<PublisherGroup>> getPublisherList() async {
    groups = await _getPublisherListFromNetwork();
    return groups!;
  }

  Future<Publisher?> getPublisher(String name) async {
    if (groups == null) await getPublisherList();
    for (var group in groups!) {
      for (var publisher in group.publisherInfo) {
        if (publisher.name == name) {
          return publisher;
        }
      }
    }
    return null;
  }

  Future<List<Publisher>> getBookedPublisherList() async {
    if (groups == null) await getPublisherList();
    List<String>? list = await _localStorage.getBookedPublishers();
    list ??= [];
    List<Publisher> publishers = [];
    for (var name in list) {
      for (var group in groups!) {
        for (var publisher in group.publisherInfo) {
          if (publisher.name == name) {
            publishers.add(publisher);
          }
        }
      }
    }
    return publishers;
  }

  Future<List<Publisher>> getVideoPublisherList() async {
    if (groups == null) await getPublisherList();
    List<Publisher> publishers = [];
    for (var group in groups!) {
      for (var publisher in group.publisherInfo) {
        if (publisher.isVideo || publisher.name == "movie") {
          publishers.add(publisher);
        }
      }
    }
    return publishers;
  }

  Future<void> operatePublisher(String id, bool add) async {
    List<String>? list = await _localStorage.getBookedPublishers();
    list ??= [];
    if (add) {
      if (!list.contains(id)) {
        list.add(id);
      }
    } else {
      list.remove(id);
    }
    await _localStorage.upsertBookedPublishers(list);
  }

  Stream<List<Feed>> getFeedListPage(
    int pageNum, {
    int limit = 10,
    String publisher = '',
    String? tagId,
    DateTime? date,
    required DataFetchPolicy fetchPolicy,
  }) async* {
    final isFetchPolicyNetworkOnly = fetchPolicy == DataFetchPolicy.networkOnly;
    final shouldSkipCacheLookup = isFetchPolicyNetworkOnly;

    if (shouldSkipCacheLookup) {
      //从网络获取
      final freshPage = await _getFeedListPageFromNetwork(pageNum,
          limit: limit, tagId: tagId, publisher: publisher, date: date);

      yield freshPage;
    } else {
      //从本地获取
      // final cachedPage = await _localStorage.getFeedListPage(
      //   pageNum);
      //
      // final isFetchPolicyCacheAndNetwork =
      //     fetchPolicy == FeedListPageFetchPolicy.cacheAndNetwork;
      //
      // final isFetchPolicyCachePreferably =
      //     fetchPolicy == FeedListPageFetchPolicy.cachePreferably;
      //
      // final shouldEmitCachedPageInAdvance =
      //     isFetchPolicyCachePreferably || isFetchPolicyCacheAndNetwork;
      //
      // if (shouldEmitCachedPageInAdvance && cachedPage != null) {
      //   yield cachedPage.toDomainModel();
      //   if (isFetchPolicyCachePreferably) {
      //     return;
      //   }
      // }

      //从网络获取
      try {
        final freshPage = await _getFeedListPageFromNetwork(pageNum,
            limit: limit, tagId: tagId, publisher: publisher, date: date);

        yield freshPage;
      } catch (_) {
        final isFetchPolicyNetworkPreferably =
            fetchPolicy == DataFetchPolicy.networkPreferably;
        // if (cachedPage != null && isFetchPolicyNetworkPreferably) {
        //   yield cachedPage.toDomainModel();
        //   return;
        // }

        rethrow;
      }
    }
  }

  Future<List<PublisherGroup>> _getPublisherListFromNetwork() async {
    try {
      //网络获取
      final apiPage = await remoteApi.getPublisherInfo();

      //缓存本地
      final shouldStoreOnCache = false;
      if (shouldStoreOnCache) {
        // final shouldEmptyCache = pageNum == 1;
        // if (shouldEmptyCache) {
        //   await _localStorage.clearFeedListPageList();
        // }

        // final cachePage = apiPage.toCacheModel();
        // await _localStorage.upsertFeedListPage(
        //   pageNum,
        //   cachePage,
        // );
      }
      List<String>? list = await _localStorage.getBookedPublishers();
      final domainPage = apiPage.map((e) {
        PublisherGroup group = e.toDomainModel();
        for (var element in group.publisherInfo) {
          element.desc = group.desc;
          element.isBooked = list?.contains(element.name) ?? false;
        }
        return group;
      }).toList();
      return domainPage;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Feed>> _getFeedListPageFromNetwork(
    int pageNum, {
    int limit = 10,
    required String publisher,
    String? tagId,
    DateTime? date,
  }) async {
    try {
      //网络获取
      List<FeedRM> apiPage;
      if (publisher == "dailyword") {
        apiPage = await remoteApi.getDailyWordListPage(date: date);
      } else if (publisher == "movie") {
        apiPage = await remoteApi.getMovieListPage(date: date);
      } else {
        apiPage = await remoteApi.getFeedListPage(
          pageNum: pageNum,
          limit: limit,
          tagId: tagId,
          publisher: publisher,
        );
        if (publisher == "basicgrammar") {
          apiPage = apiPage.reversed.toList();
        }
      }

      //缓存本地
      final shouldStoreOnCache = true;
      if (shouldStoreOnCache) {
        // final shouldEmptyCache = pageNum == 1;
        // if (shouldEmptyCache) {
        //   await _localStorage.clearFeedListPageList();
        // }

        // final cachePage = apiPage.toCacheModel();
        // await _localStorage.upsertFeedListPage(
        //   pageNum,
        //   cachePage,
        // );
      }

      final domainPage = apiPage.map((e) => e.toDomainModel()).toList();
      for (var element in domainPage) {
        _cache[element.id] = element;
      }
      return domainPage;
    } catch (_) {
      rethrow;
    }
  }

  Feed? getFeedDetails(String feedId) {
    final cachedFeed = _cache[feedId];
    return cachedFeed;
  }

  Future<String?> downloadMp3File(String feedId, String url,
      void Function(int received, int total) progressCallback) async {
    // 调用下载方法 --------做该做的事
    String? savePath = await PathUtil.getLocalStoragePath();

    if (savePath == null) {
      throw Exception("文件系统不可访问");
    }
    final directory = Directory('$savePath/mp3');
    if (!directory.existsSync()) {
      directory.createSync();
    }
    //文件是否存在
    String destination = '$savePath/mp3/$feedId.mp3';
    File file = File(destination);
    if (file.existsSync()) {
      return destination;
    }

    //下载
    bool success =
        await remoteApi.downloadFeedFile(url, destination, progressCallback);
    return success ? destination : null;
  }

// Future<void> clearCache() async {
//   await _localStorage.clear();
// }
}

enum DataFetchPolicy {
  cacheAndNetwork,
  networkOnly,
  networkPreferably,
  cachePreferably,
}
