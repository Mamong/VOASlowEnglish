import 'dart:async';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:feed_player/feed_player.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class BottomPlayerView extends StatefulWidget {
  const BottomPlayerView({super.key, this.onFeedSelected});

  final Function(String)? onFeedSelected;

  @override
  BottomPlayerViewState createState() => BottomPlayerViewState();
}

class BottomPlayerViewState extends State<BottomPlayerView> {
  late FeedAudioPlayer player;
  late StreamSubscription _indexSub;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    player = FeedAudioPlayer.instance;

    _indexSub = player.currentIndexStream.listen((event) {
      //避免push到详情页build时冲突
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _indexSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (player.currentIndex == null) {
      return Container(
        height: 0,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              widget.onFeedSelected?.call(player.currentFeed!.id);
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    player.currentFeed!.image,
                    width: 36,
                    height: 36,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Container(
                  width: 12,
                ),
                Expanded(
                    child: Marquee(
                        text: player.currentFeed!.title,
                        blankSpace: 40.0,
                        startPadding: 10.0)),
              ],
            ),
          )),
          Container(
            width: 12,
          ),
          StreamBuilder(
              stream: player.player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing;
                return IconButton(
                    onPressed: () {
                      if (playing == true) {
                        player.player.pause();
                      } else {
                        player.player.play();
                      }
                    },
                    icon: Icon(
                      playing == true
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outlined,
                      size: 24,
                    ));
              }),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return buildPlayList();
                    });
              },
              icon: const Icon(
                Icons.playlist_play,
                size: 24,
              )),
        ],
      ),
    );
  }

  Widget buildPlayList() {
    final theme = AppTheme.of(context);

    //TODO: 列表居中优化
    ScrollController? controller =
        ScrollController(initialScrollOffset: (player.currentIndex ?? 0) * 44);
    return StreamBuilder(
        stream: player.currentIndexStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          final currentIndex = snapshot.data;

          return SizedBox(
            height: 420,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.loop),
                      Text(player.loopMode.name)
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        controller: controller,
                        itemBuilder: (context, index) {
                          Feed feed = player.playList![index];
                          return GestureDetector(
                            onTap: () {
                              player.playAt(index);
                              //controller.animateTo(index*44, duration: Duration(milliseconds: 250), curve: Curves.bounceIn);
                            },
                            child: Row(
                              children: [
                                Visibility(
                                  maintainAnimation: true,
                                  maintainSize: true,
                                  maintainState: true,
                                  visible: index == currentIndex,
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.play_arrow_outlined,
                                        color: theme.feedFocusColor,
                                      )),
                                ),
                                Expanded(
                                    child: Text(
                                  feed.title,
                                  style: TextStyle(
                                      color: index == currentIndex
                                          ? theme.feedFocusColor
                                          : theme.feedTitleColor),
                                )),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.cancel_outlined)),
                              ],
                            ),
                          );
                        },
                        itemExtent: 44,
                        //separatorBuilder: (context, index) => const Divider(),
                        itemCount: player.playList!.length)),
                TextButton(
                    onPressed: () {
                      controller.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text("关闭"))
              ],
            ),
          );
        });
  }
}
