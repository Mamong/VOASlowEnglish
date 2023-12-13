part of 'publisher_picker_cubit.dart';

class PublisherPickerState{
  final List<PublisherGroup>? groups;

  final List<Publisher>? publisherList;

  PublisherPickerState({this.groups, this.publisherList});

  PublisherPickerState copyWith({
    List<PublisherGroup>? groups,
    List<Publisher>? publisherList,
  }) {
    return PublisherPickerState(
      groups: groups ?? this.groups,
      publisherList: publisherList ?? this.publisherList,
    );
  }
}