part of 'feed_list_bloc.dart';

abstract class FeedListEvent extends Equatable {
  const FeedListEvent();

  @override
  List<Object?> get props => [];
}

class FeedListRefreshed extends FeedListEvent {
  const FeedListRefreshed({this.tag});
  final String? tag;

  @override
  List<Object?> get props => [
    tag,
  ];
}

class FeedListNextPageRequested extends FeedListEvent {
  const FeedListNextPageRequested();

  @override
  List<Object?> get props => [
  ];
}