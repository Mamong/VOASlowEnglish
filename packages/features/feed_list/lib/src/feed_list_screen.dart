import 'package:component_library/component_library.dart';
import 'package:events/events.dart';
import 'package:feed_list/src/publisher_list_cubit.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bottom_player_view.dart';
import 'publisher_feed_list.dart';

typedef FeedSelected = Function(String feedId);

class FeedListScreen extends StatelessWidget {
  const FeedListScreen({
    required this.feedRepository,
    this.onFeedSelected,
    this.onPickerTapped,
    this.isVideoFeed = false,
    Key? key,
  }) : super(key: key);

  final bool isVideoFeed;
  final FeedRepository feedRepository;
  final FeedSelected? onFeedSelected;
  final VoidCallback? onPickerTapped;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublisherListCubit>(
      create: (_) => PublisherListCubit(
        feedRepository: feedRepository,
      ),
      child: FeedListview(
          isVideoFeed: isVideoFeed,
          feedRepository: feedRepository,
          onFeedSelected: onFeedSelected,
          onPickerTapped: onPickerTapped),
    );
  }
}

class FeedListview extends StatefulWidget {
  const FeedListview(
      {Key? key,
      required this.feedRepository,
      this.isVideoFeed = false,
      this.onFeedSelected,
      this.onPickerTapped})
      : super(key: key);

  final bool isVideoFeed;
  final FeedRepository feedRepository;
  final FeedSelected? onFeedSelected;
  final VoidCallback? onPickerTapped;

  @override
  FeedListViewState createState() => FeedListViewState();
}

class FeedListViewState extends State<FeedListview> {
  PublisherListCubit get _cubit => context.read<PublisherListCubit>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBus.on<SelectedPublishersChanged>().listen((event) {
      _cubit.onLoadBookedPublishers();
    });
    if (!widget.isVideoFeed) {
      _cubit.onLoadBookedPublishers();
    } else {
      _cubit.onLoadVideoPublishers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublisherListCubit, PublisherListState>(
        builder: (context, state) {
          int length = state.publisherList?.length ?? 0;
          return DefaultTabController(
              length: length,
              child: Scaffold(
                  appBar: AppBar(
                    title: TabBar(
                        isScrollable: true,
                        tabs: state.publisherList
                                ?.map((e) => Tab(text: e.publisherName))
                                .toList() ??
                            []),
                    centerTitle: true,
                    actions: <Widget>[
                      if (!widget.isVideoFeed)
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              widget.onPickerTapped?.call();
                            }),
                    ],
                  ),
                  body: length > 0
                      ? TabBarView(
                          children: state.publisherList?.map((e) {
                                return KeepAliveWrapper(
                                  child: PublisherFeedListScreen(
                                    feedRepository: widget.feedRepository,
                                    onFeedSelected: widget.onFeedSelected,
                                    publisher: e.name,
                                  ));
                              }).toList() ??
                              [],
                        )
                      : emptyView(),
                  bottomSheet: !widget.isVideoFeed
                      ? BottomPlayerView(
                          onFeedSelected: widget.onFeedSelected,
                        )
                      : null));
        });
  }

  Widget emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("还没订阅任何频道哦！"),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
              onPressed: () {
                widget.onPickerTapped?.call();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(72, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "前往订阅",
                    style: TextStyle(fontSize: FontSize.normal),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                  )
                ],
              ))
        ],
      ),
    );
  }
}
