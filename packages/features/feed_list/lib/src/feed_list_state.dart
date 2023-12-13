part of 'feed_list_bloc.dart';

class FeedListState extends Equatable {

  final String publisher;

  final String? tag;

  final bool isRefresh;

  /// Holds all of the items from the pages you have loaded so far.
  final List<Feed>? itemList;

  /// The next page to be fetched, or `null` if you have already loaded the entire list.
  ///
  /// Besides determining which page should be asked next, it also determines
  /// whether you need a loading indicator at the bottom to indicate you haven't
  /// fetched all pages yet.
  final int? nextPage;

  /// Indicates an error occurred trying to fetch any page of quotes.
  ///
  /// If both this property and [itemList] holds values, that means the error
  /// occurred trying to fetch a subsequent page. If, on the other hand, this
  /// property has a value but [itemList] doesn't, that means the error occurred
  /// when fetching the first page.
  final dynamic error;

  /// Indicates an error occurred trying to refresh the list.
  ///
  /// Used to display a snackbar to indicate the failure.
  final dynamic refreshError;

  const FeedListState(
      {
      required  this.publisher,
      this.tag,
      this.isRefresh = false,
      this.itemList,
      this.nextPage,
      this.error,
      this.refreshError});

  /// Auxiliary constructor that facilitates building the state for when the app
  /// has successfully loaded a new page.
  const FeedListState.success({
    required String publisher,
    required String? tag,
    required int? nextPage,
    required List<Feed> itemList,
    required bool isRefresh,
  }) : this(
    publisher: publisher,
            tag: tag,
            nextPage: nextPage,
            itemList: itemList,
            isRefresh: isRefresh);

  /// Auxiliary function that creates a copy of the current state with a new
  /// value for the [error] property.
  FeedListState copyWithNewError(
    dynamic error,
  ) =>
      FeedListState(
        publisher: publisher,
        tag: tag,
        itemList: itemList,
        nextPage: nextPage,
        isRefresh: isRefresh,
        error: error,
        refreshError: null,
      );

  /// Auxiliary function that creates a copy of the current state with a new
  /// value for the [refreshError] property.
  FeedListState copyWithNewRefreshError(
    dynamic refreshError,
  ) =>
      FeedListState(
        publisher: publisher,
        tag: tag,
        itemList: itemList,
        nextPage: nextPage,
        isRefresh: isRefresh,
        error: error,
        refreshError: refreshError,
      );

  @override
  List<Object?> get props => [
    publisher,
        tag,
        itemList,
        nextPage,
        isRefresh,
        error,
        refreshError,
      ];
}
