import 'package:domain_models/domain_models.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'publisher_picker_state.dart';

class PublisherPickerCubit extends Cubit<PublisherPickerState> {
  PublisherPickerCubit({
    required this.feedRepository,
  }) : super(
          PublisherPickerState(),
        );

  final FeedRepository feedRepository;

  List<PublisherGroup>? publisherGroups;

  ///finish selecting
  void onSelectPublishersChanged() async {
    publisherGroups = await feedRepository.getPublisherList();
    await updateList();
  }

  ///select or deselect one
  void onSelectPublisherChanged(Publisher publisher) async {
    publisher.isBooked = !publisher.isBooked;
    await feedRepository.operatePublisher(publisher.name, publisher.isBooked);

    await updateList();
  }

  Future updateList() async {
    final publishers = await feedRepository.getBookedPublisherList();
    PublisherGroup bookedGroup = PublisherGroup(
      desc: '已订阅栏目',
      publisherInfo: publishers,
    );

    List<PublisherGroup> groups = [bookedGroup];
    groups.addAll(publisherGroups!.map((e) => PublisherGroup(
      desc: e.desc,
      publisherInfo:
      e.publisherInfo.where((element) => !element.isBooked).toList(),
    )));

    final newScreenState = state.copyWith(
      groups: groups,
    );
    emit(newScreenState);
  }
}
