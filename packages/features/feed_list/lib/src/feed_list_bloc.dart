import 'package:domain_models/domain_models.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'feed_list_event.dart';

part 'feed_list_state.dart';

class FeedListBloc extends Bloc<FeedListEvent, FeedListState> {
  FeedListBloc(
      {required FeedRepository feedRepository,
      required String publisher,
      String? tag})
      : _feedRepository = feedRepository,
        super(FeedListState(publisher: publisher, tag: tag)) {
    _registerEventsHandler();
  }

  final FeedRepository _feedRepository;

  void _registerEventsHandler() {
    on<FeedListEvent>((event, emitter) async {
      if (event is FeedListRefreshed) {
        await _handleFeedListRefreshed(emitter, event);
      } else if (event is FeedListNextPageRequested) {
        await _handleFeedListNextPageRequested(emitter, event);
      }
    });
  }

  Future<void> _handleFeedListRefreshed(
    Emitter emitter,
    FeedListRefreshed event,
  ) {
    final firstPageFetchStream = _fetchFeedPage(
      0,
      // Since the user is asking for a refresh, you don't want to get cached
      // quotes, thus the `networkOnly` fetch policy makes the most sense.
      publisher: state.publisher,
      tagId: event.tag,
      fetchPolicy: DataFetchPolicy.networkOnly,
      isRefresh: true,
    );

    return emitter.onEach<FeedListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  Future<void> _handleFeedListNextPageRequested(
    Emitter emitter,
    FeedListNextPageRequested event,
  ) {
    emitter(
      state.copyWithNewError(null),
    );

    final nextPageFetchStream = _fetchFeedPage(
      state.nextPage!,
      publisher: state.publisher,
      tagId: state.tag,
      date: state.itemList?.last.updatedAt,
      // The `networkPreferably` fetch policy prioritizes fetching the new page
      // from the server, and, if it fails, try grabbing it from the cache.
      fetchPolicy: DataFetchPolicy.networkPreferably,
    );

    return emitter.onEach<FeedListState>(
      nextPageFetchStream,
      onData: emitter,
    );
  }

  //
  Stream<FeedListState> _fetchFeedPage(int page,
      {required DataFetchPolicy fetchPolicy,
      bool isRefresh = false,
      required String publisher,
      String? tagId,
      int limit = 10,
      DateTime? date}) async* {
    if (publisher == "basicgrammar") {
      limit = 100;
    }
    final pagesStream = _feedRepository.getFeedListPage(page,
        limit: limit,
        publisher: publisher,
        tagId: tagId,
        fetchPolicy: fetchPolicy,
        date: date);

    try {
      await for (final newPage in pagesStream) {
        final newItemList = newPage;
        final oldItemList = state.itemList ?? [];
        final completeItemList =
            isRefresh || page == 0 ? newItemList : (oldItemList + newItemList);

        final nextPage =
            (newPage.length < limit || publisher == "movie") ? null : page + 1;
        yield FeedListState.success(
          publisher: state.publisher,
          tag: tagId,
          nextPage: nextPage,
          itemList: completeItemList,
          isRefresh: isRefresh,
        );
      }
    } catch (error) {
      if (isRefresh) {
        yield state.copyWithNewRefreshError(
          error,
        );
      } else {
        yield state.copyWithNewError(
          error,
        );
      }
    }
  }
}
