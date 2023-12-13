import 'package:domain_models/domain_models.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'publisher_list_state.dart';

class PublisherListCubit extends Cubit<PublisherListState> {
  PublisherListCubit({
    required this.feedRepository,
  }) : super(
          PublisherListState(),
        );

  final FeedRepository feedRepository;

  void onLoadBookedPublishers() async {
    final publishers = await feedRepository.getBookedPublisherList();

    final newScreenState = PublisherListState(
      publisherList: publishers,
    );
    emit(newScreenState);
  }

  void onLoadVideoPublishers() async {
    final publishers = await feedRepository.getVideoPublisherList();

    final newScreenState = PublisherListState(
      publisherList: publishers,
    );
    emit(newScreenState);
  }
}