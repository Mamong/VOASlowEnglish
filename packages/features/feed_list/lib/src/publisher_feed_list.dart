import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:feed_list/src/publisher_cubit.dart';
import 'package:feed_player/feed_player.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../feed_list.dart';
import 'feed_cards.dart';
import 'feed_list_bloc.dart';

class PublisherFeedListScreen extends StatelessWidget {
  const PublisherFeedListScreen({
    required this.feedRepository,
    this.onFeedSelected,
    required this.publisher,
    this.tag,
    this.isRoute = false,
    Key? key,
  }) : super(key: key);

  final String publisher;
  final String? tag;
  final FeedRepository feedRepository;
  final FeedSelected? onFeedSelected;

  //单独页面还是内嵌视图
  final bool isRoute;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FeedListBloc(
              feedRepository: feedRepository, publisher: publisher, tag: tag),
        ),
        BlocProvider<PublisherCubit>(
            create: (_) => PublisherCubit(
                  feedRepository: feedRepository,
                ))
      ],
      child: FeedListPagerView(
        isRoute: isRoute,
        publisher: publisher,
        tag: tag,
        onFeedSelected: onFeedSelected,
      ),
    );
  }
}

class FeedListPagerView extends StatefulWidget {
  const FeedListPagerView(
      {Key? key,
      required this.publisher,
      this.tag,
      this.isRoute = false,
      this.onFeedSelected})
      : super(key: key);

  final bool isRoute;
  final FeedSelected? onFeedSelected;

  final String publisher;
  final String? tag;

  @override
  FeedListPagerState createState() => FeedListPagerState();
}

class FeedListPagerState extends State<FeedListPagerView>
    with SingleTickerProviderStateMixin {
  FeedListBloc get _bloc => context.read<FeedListBloc>();

  PublisherCubit get _cubit => context.read<PublisherCubit>();

  TabController? _tabController;
  final FeedAudioPlayer _audioPlayer = FeedAudioPlayer();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cubit.onLoadPublisher(widget.publisher);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return BlocBuilder<PublisherCubit, PublisherState>(
        builder: (context, state) {
      Publisher? publisher = state.publisher;
      if (widget.isRoute) {
        return Scaffold(
            appBar: AppBar(
              title: Text(publisher?.publisherName ?? "",
                  style: TextStyle(fontSize: theme.navBarTitleFontSize)),
            ),
            body: feedContent(publisher));
      } else {
        return feedContent(publisher);
      }
    });
  }

  Widget feedContent(Publisher? publisher) {
    return Column(
      children: [
        if (publisher != null && publisher.tags != null)
          TabBar.secondary(
              tabAlignment: TabAlignment.start,
              controller: createTabController(publisher),
              isScrollable: true,
              tabs: [PublisherTag(tagId: "", tagName: "全部"), ...publisher.tags!]
                  .map((e) => Tab(text: e.tagName))
                  .toList()),
        BlocConsumer<FeedListBloc, FeedListState>(listener: (context, state) {
          if (state.isRefresh || state.refreshError != null) {
            _refreshController.refreshCompleted();
          } else {
            _refreshController.loadComplete();
          }
          if (state.nextPage != null || state.error != null) {
            _refreshController.resetNoData();
          } else {
            _refreshController.loadNoData();
          }

          if (state.refreshError != null || state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "数据加载失败",
                ),
              ),
            );
          }
        }, builder: (context, state) {
          return Expanded(
              child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: () {
              _bloc.add(FeedListRefreshed(tag: state.tag));
            },
            onLoading: () {
              _bloc.add(const FeedListNextPageRequested());
            },
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final feed = state.itemList![index];
                  late Widget card;
                  if (state.publisher == "movie") {
                    card = MovieFeedView(
                      feed: feed,
                    );
                  } else if (state.publisher == "dailyword") {
                    card = WordFeedView(
                      feed: feed,
                    );
                  } else {
                    if (index == 0) {
                      card = BigFeedView(feed: feed);
                    } else {
                      card = SmallFeedView(feed: feed);
                    }
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (feed.videoUrl != null) {
                        await _audioPlayer.pause();
                        FeedVideoPlayer.instance
                            .updatePlayList(state.itemList!);
                      } else if (feed.type == "syncText") {
                        _audioPlayer.updatePlayList(state.itemList!);
                      }
                      widget.onFeedSelected?.call(feed.id);
                    },
                    child: card,
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Container(height: 12),
                itemCount: state.itemList?.length ?? 0),
          ));
        })
      ],
    );
  }

  TabController? createTabController(Publisher publisher) {
    if (_tabController == null) {
      if (publisher.tags != null) {
        int index = 0;
        if (widget.tag != null) {
          index = publisher.tags!
              .indexWhere((element) => element.tagId == widget.tag);
          index++;
        }
        _tabController = TabController(
            initialIndex: index,
            length: publisher.tags!.length + 1,
            vsync: this);
        _tabController!.addListener(() {
          int index = _tabController!.index;
          String? tag;
          if (index > 0) tag = publisher.tags![index - 1].tagId;
          if (!_tabController!.indexIsChanging) {
            _bloc.add(FeedListRefreshed(tag: tag));
          }
        });
      }
    }
    return _tabController;
  }
}




