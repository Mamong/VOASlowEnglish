import 'dart:math';

import 'package:feed_player/feed_player.dart';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;

  //final Duration bufferedPosition;
  final ValueChanged<Duration>? onChangeStart;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    //required this.bufferedPosition,
    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
        child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
              color: Color(0xffdfdfdf),
              offset: Offset(0.0, -2.0),
              //阴影y轴偏移量
              blurRadius: 4,
              //阴影模糊程度
              spreadRadius: 0,
              //阴影扩散程度
              blurStyle: BlurStyle.outer),
        ],
        // border: Border(
        //   top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
        // ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Text(
              widget.position.toTimestamp(),
            ),
          ),
          Expanded(
            child: Slider(
              min: 0.0,
              max: widget.duration.inSeconds.toDouble(),
              //音频有问题，需要防御
              value: min(widget.position.inSeconds.toDouble(),
                  widget.duration.inSeconds.toDouble()),
              onChangeStart: (value) {
                widget.onChangeStart?.call(Duration(seconds: value.round()));
              },
              onChangeEnd: (value) {
                widget.onChangeEnd?.call(Duration(seconds: value.round()));
              },
              onChanged: (double value) {
                widget.onChanged?.call(Duration(seconds: value.round()));
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              widget.duration.toTimestamp(),
            ),
          ),
        ],
      ),
    ));
  }
}

class ControlButtons extends StatelessWidget {
  const ControlButtons(
    this.player, {
    Key? key,
    required this.bufferedProgress,
    // required this.modeName,
    this.onTapLoop,
    this.onTapPrev,
    this.onTapNext,
    this.onTapSettings,
  }) : super(key: key);

  final MediaPlayer player;
  final double bufferedProgress;

  // final String modeName;

  final Function? onTapLoop;
  final Function? onTapPrev;

  // final Function? onTapPlay;
  final Function? onTapNext;
  final Function? onTapSettings;

  @override
  Widget build(BuildContext context) {
    String modeName = player.loopMode.name;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatefulBuilder(builder: (context, setState) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Text(
                modeName,
                style: const TextStyle(fontSize: 9),
              ),
              IconButton(
                  onPressed: () {
                    onTapLoop?.call();
                    setState(() => modeName = player.loopMode.name);
                  },
                  style:IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  icon: const Icon(
                    Icons.loop,
                    size: 36,
                  )),
            ],
          );
        }),
        IconButton(
            onPressed: () {
              onTapPrev?.call();
            },
            style:IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            icon: const Icon(
              Icons.arrow_circle_up,
              size: 36,
            )),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (bufferedProgress < 1.0) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 48.0,
                height: 48.0,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  value: bufferedProgress,
                ),
              );
            }

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return IconButton(
                icon: const Icon(Icons.play_circle_outline),
                iconSize: 48.0,
                style:IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: player.play,
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_circle_outline),
                iconSize: 48.0,
                style:IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause_circle_outline),
                iconSize: 48.0,
                style:IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 48.0,
                style:IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () => player.seekTo(Duration.zero),
              );
            }
          },
        ),
        IconButton(
            onPressed: () {
              onTapNext?.call();
            },
            style:IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            icon: const Icon(
              Icons.arrow_circle_down,
              size: 36,
            )),
        IconButton(
            onPressed: () {
              onTapSettings?.call();
            },
            style:IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            icon: const Icon(
              Icons.list,
              size: 36,
            )),
      ],
    );
  }
}

// class FeedDetailsBottomView extends StatelessWidget {
//   const FeedDetailsBottomView({
//     super.key,
//     this.onTapLoop,
//     this.onTapPrev,
//     this.onTapPlay,
//     this.onTapNext,
//     this.onTapSettings,
//     required this.bufferedProgress,
//     required this.duration,
//     required this.position,
//     required this.player,
//     this.onChanged,
//     this.onChangeEnd,
//   });
//
//   final Function? onTapLoop;
//   final Function? onTapPrev;
//   final Function? onTapPlay;
//   final Function? onTapNext;
//   final Function? onTapSettings;
//
//   final double bufferedProgress;
//   final Duration duration;
//   final Duration position;
//   final ValueChanged<Duration>? onChanged;
//   final ValueChanged<Duration>? onChangeEnd;
//
//   final FeedAudioPlayer player;
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         bottom: true,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             boxShadow: const [
//               BoxShadow(
//                   color: Color(0xFFDFDFDF),
//                   offset: Offset(0.0, -2.0),
//                   //阴影y轴偏移量
//                   blurRadius: 4,
//                   //阴影模糊程度
//                   spreadRadius: 0,
//                   //阴影扩散程度
//                   blurStyle: BlurStyle.outer),
//             ],
//             // border: Border(
//             //   top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
//             // ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 60,
//                     child: Text(position.toTimestamp()),
//                   ),
//                   Expanded(
//                     child: Slider(
//                       min: 0.0,
//                       max: duration.inSeconds.toDouble(),
//                       value: position.inSeconds.toDouble(),
//                       onChangeStart: (value) {
//                         player.player.pause();
//                       },
//                       onChangeEnd: (value) {
//                         onChangeEnd?.call(Duration(seconds: value.round()));
//                         player.player.play();
//                       },
//                       onChanged: (double value) {
//                         onChanged?.call(Duration(seconds: value.round()));
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 60,
//                     child: Text(duration.toTimestamp()),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                       onPressed: () {
//                         onTapLoop?.call();
//                       },
//                       icon: const Icon(
//                         Icons.loop,
//                         size: 24,
//                       )),
//                   IconButton(
//                       onPressed: () {
//                         onTapPrev?.call();
//                       },
//                       icon: const Icon(
//                         Icons.arrow_circle_up,
//                         size: 24,
//                       )),
//                   StreamBuilder<PlayerState>(
//                     stream: player.player.playerStateStream,
//                     builder: (context, snapshot) {
//                       final playerState = snapshot.data;
//                       final processingState = playerState?.processingState;
//                       final playing = playerState?.playing;
//                       if (processingState == ProcessingState.loading ||
//                           processingState == ProcessingState.buffering) {
//                         return Container(
//                           margin: const EdgeInsets.all(8.0),
//                           width: 42.0,
//                           height: 42.0,
//                           child: CircularProgressIndicator(
//                             backgroundColor: Colors.grey[200],
//                             valueColor:
//                                 const AlwaysStoppedAnimation(Colors.blue),
//                             value: bufferedProgress,
//                           ),
//                         );
//                       } else if (playing != true) {
//                         return IconButton(
//                           icon: const Icon(Icons.play_circle_outline),
//                           iconSize: 42.0,
//                           onPressed: player.player.play,
//                         );
//                       } else if (processingState != ProcessingState.completed) {
//                         return IconButton(
//                           icon: const Icon(Icons.pause_circle_outline),
//                           iconSize: 42.0,
//                           onPressed: player.player.pause,
//                         );
//                       } else {
//                         return IconButton(
//                           icon: const Icon(Icons.replay),
//                           iconSize: 42.0,
//                           onPressed: () => player.player.seek(Duration.zero,
//                               index: player.player.effectiveIndices!.first),
//                         );
//                       }
//                     },
//                   ),
//                   IconButton(
//                       onPressed: () {
//                         onTapNext?.call();
//                       },
//                       icon: const Icon(
//                         Icons.arrow_circle_down,
//                         size: 24,
//                       )),
//                   IconButton(
//                       onPressed: () {
//                         onTapSettings?.call();
//                       },
//                       icon: const Icon(
//                         Icons.list,
//                         size: 24,
//                       )),
//                 ],
//               )
//             ],
//           ),
//         ));
//   }
// }

/// convert Duration to 00:00
extension DurationConvert on Duration {
  String toTimestamp() {
    int seconds = inSeconds.toInt();
    int minute = seconds ~/ 60;
    int second = seconds % 60;
    return "${minute.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}";
  }
}
