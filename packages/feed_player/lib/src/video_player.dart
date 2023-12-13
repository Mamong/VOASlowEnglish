import 'package:domain_models/domain_models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import 'media_player.dart';

class FeedVideoPlayer extends MediaPlayer {
  factory FeedVideoPlayer() => _singleton;

  FeedVideoPlayer._();

  static final FeedVideoPlayer _singleton = FeedVideoPlayer._();

  static FeedVideoPlayer get instance => FeedVideoPlayer();

  VideoPlayerController? player;

  FeedLoopMode _loopMode = FeedLoopMode.off;

  @override
  FeedLoopMode get loopMode => _loopMode;

  final _currentPIndexSubject = BehaviorSubject<int?>(sync: true);

  @override
  int? get currentParagraphIndex => _currentPIndexSubject.valueOrNull;

  @override
  Stream<int?> get currentParagraphIndexStream => _currentPIndexSubject.stream;

  final _currentIndexSubject = BehaviorSubject<int?>(sync: true);

  @override
  int? get currentIndex => _currentIndexSubject.valueOrNull;

  @override
  Stream<int?> get currentIndexStream => _currentIndexSubject.stream;

  final _downloadProgressSubject = BehaviorSubject<double>();

  @override
  Stream<double> get downloadProgressStream => _downloadProgressSubject.stream;

  final _positionSubject = BehaviorSubject<Duration>();

  @override
  Stream<Duration> get positionStream => _positionSubject.stream;

  final _durationSubject = BehaviorSubject<Duration?>();

  @override
  Stream<Duration?> get durationStream => _durationSubject.stream;

  final _playStateSubject = BehaviorSubject<PlayerState>();

  @override
  Stream<PlayerState> get playerStateStream => _playStateSubject.stream;

  Feed? _lastFeed;

  List<Feed>? _playList;

  @override
  List<Feed>? get playList => _playList;

  void attachToController(VideoPlayerController controller) {
    if (player != null) {
      detach();
    }
    player = controller;
    setLoopMode(loopMode);

    controller.addListener(() async {
      ProcessingState state = ProcessingState.loading;
      if (controller.value.isInitialized) {
        state = ProcessingState.ready;
      }
      if (controller.value.isBuffering) {
        //加载中
        state = ProcessingState.buffering;
      } else if (controller.value.isCompleted) {
        state = ProcessingState.completed;
      } else {
        state = ProcessingState.idle;
      }

      _playStateSubject.add(PlayerState(controller.value.isPlaying, state));
      _downloadProgressSubject.add(1.0);

      _durationSubject.add(controller.value.duration);
      _positionSubject.add(controller.value.position);
      await _updatePosition(controller.value.position);

      if (controller.value.isCompleted) {
        //播放下一首
        if (_loopMode == FeedLoopMode.list) {
          if (currentIndex! < playList!.length - 1) {
            playAt(currentIndex! + 1);
          }
        }
      }
    });
  }

  void detach() {
    player?.dispose();
    player = null;
  }

  void updatePlayList(List<Feed> feeds) {
    _playList = List<Feed>.from(feeds);
    // final _playlist = ConcatenatingAudioSource(children: feeds.map((e) => AudioSource.uri(
    //   Uri.parse(e.url),
    //   tag: AudioMetadata(
    //     album: "Science Friday",
    //     title: "A Salute To Head-Scratching Science",
    //     artwork:
    //     "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    //   ),
    // )).toList());
  }

  void removeItemAt(int index) {
    _playList?.removeAt(index);
    if (currentIndex == index) {
      playAt(index);
    }
  }

  @override
  Future<void> playAt(int index) async {
    if (playList == null) return;
    if (playList!.length - 1 < index) return;

    Feed feed = playList![index];
    _lastFeed = feed;
    _currentPIndexSubject.add(null);

    //下载

    VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(feed.videoUrl!))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            //setState(() {});
            _currentIndexSubject.add(index);
            player?.play();
          });
    attachToController(controller);
  }

  @override
  Future seekToParagraph(int index) async {
    super.seekToParagraph(index);
    _currentPIndexSubject.add(index);
  }

  @override
  Future<void> setLoopMode(FeedLoopMode mode) async {
    _loopMode = mode;
    switch (mode) {
      case FeedLoopMode.feed:
        await player?.setLooping(true);
      case FeedLoopMode.paragraph:
      case FeedLoopMode.list:
      case FeedLoopMode.off:
        await player?.setLooping(false);
    }
  }

  @override
  Future<void> pause() async {
    await player?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await player?.seekTo(position);
  }

  @override
  Future<void> play() async {
    await player?.play();
  }

  Future<void> _updatePosition(Duration event) async {
    if (currentFeed == null) return;

    final int index;
    if (_loopMode == FeedLoopMode.paragraph) {
      index =
          (currentParagraphIndex ?? 0).clamp(0, currentFeed!.captions.length);
      Map<String, String> caption = currentFeed!.captions[index];
      String start = caption["start"]!;
      String end = caption["end"]!;
      Duration clipStart = start.toDuration();
      Duration clipEnd = end.toDuration();
      if (event >= clipEnd || event < clipStart) {
        await seekTo(clipStart);
      }
    } else {
      index = currentFeed!.captions.indexWhere((element) {
        String start = element["start"]!;
        String end = element["end"]!;
        Duration startDuration = start.toDuration();
        Duration endDuration = end.toDuration();
        return endDuration >= event && startDuration <= event;
      });
    }
    //seeking错误
    if (currentParagraphIndex != index && index != -1) {
      _currentPIndexSubject.add(index);
    }
  }
}
