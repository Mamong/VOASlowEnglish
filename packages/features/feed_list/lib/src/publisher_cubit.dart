import 'package:domain_models/domain_models.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'publisher_state.dart';

class PublisherCubit extends Cubit<PublisherState> {
  PublisherCubit({
    required this.feedRepository,
  }) : super(
    PublisherState(),
  );

  final FeedRepository feedRepository;

  void onLoadPublisher(String name) async {
    final publisher = await feedRepository.getPublisher(name);

    final newScreenState = PublisherState(
      publisher: publisher,
    );
    emit(newScreenState);
  }
}