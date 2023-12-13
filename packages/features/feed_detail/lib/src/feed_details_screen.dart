import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:feed_player/feed_player.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import 'feed_details_bottom.dart';

class FeedDetailsScreen extends StatelessWidget {
  const FeedDetailsScreen({
    required this.feedId,
    required this.feedRepository,
    Key? key,
  }) : super(key: key);

  final String feedId;
  final FeedRepository feedRepository;

  @override
  Widget build(BuildContext context) {
    return FeedDetailsView(
      feedId: feedId,
      feedRepository: feedRepository,
    );
  }
}

class FeedDetailsView extends StatefulWidget {
  const FeedDetailsView({
    Key? key,
    required this.feedId,
    required this.feedRepository,
  }) : super(key: key);

  final String feedId;
  final FeedRepository feedRepository;

  @override
  FeedDetailsViewState createState() => FeedDetailsViewState();
}

class FeedDetailsViewState extends State<FeedDetailsView> {
  Map<int, Rect> rects = {};
  Rect? scrollViewRect;
  int selectedIndex = 0;

  late Feed feed;
  bool touching = false;

  bool get isVideo => feed.videoUrl != null;

  //FeedAudioPlayer? _audioPlayer;

  late MediaPlayer _feedPlayer;

  //late VideoPlayerController _controller;
  late StreamSubscription _positionSub;
  late StreamSubscription _indexSub;

  @override
  void initState() {
    super.initState();
    //获取feed
    feed = widget.feedRepository.getFeedDetails(widget.feedId)!;

    if (isVideo) {
      _feedPlayer = FeedVideoPlayer();
    } else if (feed.type == "syncText") {
      _feedPlayer = FeedAudioPlayer();
    }

    if (feed.type == "syncText" || isVideo) {
      _feedPlayer.playFeed(feed);
      _positionSub = _feedPlayer.currentParagraphIndexStream.listen((event) {
        updateFeedLocation(event);
      });
      _indexSub = _feedPlayer.currentIndexStream.listen((event) {
        if (feed.id != _feedPlayer.currentFeed!.id) {
          feed = _feedPlayer.currentFeed!;
          rects.clear();
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (feed.type == "syncText" || isVideo) {
      _positionSub.cancel();
      _indexSub.cancel();
    }
    if (feed.videoUrl != null) {
      (_feedPlayer as FeedVideoPlayer).detach();
      //_controller.dispose();
    }
  }

  Future<void> scrollToTop() async {
    setState(() {
      selectedIndex = 0;
    });
    ScrollController? controller = PrimaryScrollController.of(context);
    controller.animateTo(0,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> initCurrentLocation() async {
    updateFeedLocation(_feedPlayer.currentParagraphIndex);
  }

  Future<void> updateFeedLocation(int? index) async {
    // print("object:$index,$selectedIndex");
    if (touching) return;
    if (index == null || index == 0) {
      scrollToTop();
      return;
    }
    if (selectedIndex == index) return;
    await scrollToIndex(index);
  }

  Future<void> scrollToIndex(int index) async {
    final rect = rects[index];
    if (rect != null && scrollViewRect != null) {
      setState(() {
        selectedIndex = index;
      });
      //为了点击状态栏回到顶部，不能使用自定义的ScrollController
      ScrollController? controller = PrimaryScrollController.of(context);

      final maxScrollExtent = controller.position.maxScrollExtent;
      final scrollViewSize = scrollViewRect!.size;
      //当前项目在scrollview中的相对位置
      final itemSize = rect.size;
      final itemPosition = rect.topLeft;

      //当前项目在scrollview中的绝对位置
      final initialOffset = itemPosition.dy;
      //当前项目滚动到屏幕中间的偏移量
      final targetOffset =
          initialOffset - scrollViewSize.height / 2 + itemSize.height / 2;

      late final double offset;
      if (targetOffset < 0) {
        offset = 0;
      } else if (targetOffset > maxScrollExtent) {
        offset = maxScrollExtent;
      } else {
        offset = targetOffset;
      }
      await controller.animateTo(offset,
          duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, double, Duration?, PositionData>(
          _feedPlayer.positionStream,
          _feedPlayer.downloadProgressStream,
          _feedPlayer.durationStream,
          (position, downloadProgress, reportedDuration) {
        final duration = reportedDuration ?? Duration.zero;
        return PositionData(position, downloadProgress, duration);
      });

  @override
  Widget build(BuildContext context) {
    late Widget content, bottom;
    if (feed.type == "syncText" || isVideo) {
      content = syncTextContent();
      bottom = bottomBar();
    } else {
      content = articleContent();
      bottom = const SizedBox(
        height: 0,
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: isVideo,
      appBar: AppBar(
        forceMaterialTransparency: isVideo,
        systemOverlayStyle: isVideo ? SystemUiOverlayStyle.light : null,
        backgroundColor: isVideo ? Colors.transparent : null,
        foregroundColor: isVideo ? Colors.white : null,
        actions: [
          IconButton(icon: const Icon(Icons.star_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: content,
      bottomNavigationBar: bottom,
    );
  }

  Widget articleContent() {
    //final theme = AppTheme.of(context);
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: feed.image,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                innerAudioPlayer(),
                const SizedBox(
                  height: 12,
                ),
                Text(feed.text)
              ],
            ))
      ],
    ));
  }

  Widget innerAudioPlayer() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.play_circle_outline,
                  size: 32,
                )),
            Expanded(
                child: Column(
              children: [
                Slider(value: 0.0, onChanged: (double value) {}),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(feed.url == null ? "达人配音尚未出炉" : "原声"),
                    const Text("00:06")
                  ],
                )
              ],
            ))
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        const Divider(
          height: 1,
        )
      ],
    );
  }

  /// Keep video ratio with fixed height, may leave black or clip in width.
  Widget innerVideoPlayer() {
    VideoPlayerController? controller = (_feedPlayer as FeedVideoPlayer).player;
    double padding = MediaQuery.of(context).padding.top;
    double headerHeight = 260;
    return Container(
        height: headerHeight,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: padding),
        decoration: const BoxDecoration(color: Colors.black),
        child: OverflowBox(
          alignment: Alignment.center,
          minHeight: headerHeight - padding,
          maxHeight: headerHeight - padding,
          maxWidth: double.infinity,
          child: controller != null && controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                )
              : SizedBox(
                  height: headerHeight - padding,
                ),
        ));
  }

  Widget syncTextContent() {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (feed.videoUrl != null) innerVideoPlayer(),
        Expanded(
            child: AfterLayout(
          callback: (RenderAfterLayout value) {
            if (scrollViewRect != null) return;
            if (value.size.height == 0) return;
            scrollViewRect = value.localToGlobal(
                  Offset.zero,
                  ancestor: context.findRenderObject(),
                ) &
                value.size;
            //刚进来时候的位置更新
            initCurrentLocation();
          },
          child: Listener(
              onPointerDown: (PointerDownEvent event) {
                touching = true;
              },
              onPointerUp: (PointerUpEvent event) {
                touching = false;
              },
              child: SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.all(18),
                      child: Builder(
                        builder: (BuildContext context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isVideo)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(feed.title,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: FontSize.large2,
                                            fontWeight: FontWeight.bold,
                                            color: theme.feedTitleColor)),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Image.network(
                                      feed.image,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ...List.generate(feed.captions.length,
                                  (index) => captionItem(index, context))
                            ],
                          );
                        },
                      )))),
        ))
      ],
    );
  }

  Widget captionItem(int index, BuildContext context) {
    final theme = AppTheme.of(context);
    final element = feed.captions[index];
    return GestureDetector(
      onTap: () async {
        await _feedPlayer.seekToParagraph(index);
      },
      child: AfterLayout(
        callback: (RenderAfterLayout value) {
          //我们需要获取的是AfterLayout子组件相对于Stack的Rect
          if (rects[index] != null) return;
          rects[index] = value.localToGlobal(
                Offset.zero,
                ancestor: context.findRenderObject(),
              ) &
              value.size;
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (element["english"] != null)
            Text(
              element["english"]!,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: index == selectedIndex
                      ? theme.feedFocusColor
                      : theme.feedEnColor),
            ),
          if (element["chinese"] != null)
            Text(
              element["chinese"]!,
              style: TextStyle(
                  fontSize: 14,
                  height: 2,
                  color: index == selectedIndex
                      ? theme.feedFocusColor
                      : theme.feedZhColor),
            ),
          const SizedBox(
            height: 24,
          ),
        ]),
      ),
    );
  }

  Widget bottomBar() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        final positionData = snapshot.data;
        return SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  //bufferedProgress: positionData?.bufferedPosition ?? 0,
                  onChangeStart: (newPosition) {
                    _feedPlayer.pause();
                  },
                  onChanged: (newPosition) {
                    _feedPlayer.seekTo(newPosition);
                  },
                  onChangeEnd: (newPosition) {
                    _feedPlayer.play();
                  },
                ),
                ControlButtons(
                  _feedPlayer,
                  bufferedProgress: positionData?.bufferedPosition ?? 0,
                  onTapLoop: () async {
                    await _feedPlayer.tangleLoopMode();
                  },
                  onTapPrev: () async {
                    int newIndex = selectedIndex - 1;
                    newIndex = newIndex < 0 ? 0 : newIndex;
                    await _feedPlayer.seekToParagraph(newIndex);
                  },
                  onTapNext: () async {
                    int newIndex = (selectedIndex + 1) % feed.captions.length;
                    await _feedPlayer.seekToParagraph(newIndex);
                  },
                  onTapSettings: () {},
                )
              ],
            ));
      },
    );
  }
}

class PositionData {
  final Duration position;
  final double bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
