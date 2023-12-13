import 'package:domain_models/domain_models.dart';
import 'package:feed_player/src/media_player.dart';
import 'package:just_audio/just_audio.dart';
//import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';



class FeedAudioPlayer extends MediaPlayer {
  factory FeedAudioPlayer() => _singleton;

  FeedAudioPlayer._(){
    // JustAudioBackground.init(
    //   androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    //   androidNotificationChannelName: 'Audio playback',
    //   androidNotificationOngoing: true,
    // );

    player = AudioPlayer();
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        //播放下一首
        if (_loopMode == FeedLoopMode.list) {
          if (currentIndex! < playList!.length - 1) {
            playAt(currentIndex! + 1);
          }
        }
      }
    });

    player.positionStream.listen((event) async {
      await _updatePosition(event);
    });
  }

  static final FeedAudioPlayer _singleton = FeedAudioPlayer._();

  static FeedAudioPlayer get instance => FeedAudioPlayer();

  late final AudioPlayer player;

  late LockCachingAudioSource _audioSource;

  FeedLoopMode _loopMode = FeedLoopMode.off;

  @override
  FeedLoopMode get loopMode => _loopMode;

  final _currentPIndexSubject = BehaviorSubject<int?>(sync: true);

  @override
  int? get currentParagraphIndex => _currentPIndexSubject.valueOrNull;

  @override
  Stream<int?> get currentParagraphIndexStream => _currentPIndexSubject.stream;

  List<Feed>? _playList;

  @override
  List<Feed>? get playList => _playList;

  final _currentIndexSubject = BehaviorSubject<int?>(sync: true);

  @override
  int? get currentIndex => _currentIndexSubject.valueOrNull;

  @override
  Stream<int?> get currentIndexStream => _currentIndexSubject.stream;

  Feed? _lastFeed;

  @override
  Feed? get currentFeed =>
      currentIndex == null ? null : playList?[currentIndex!];

  final _downloadProgressSubject = BehaviorSubject<double>();

  @override
  Stream<double> get downloadProgressStream => _downloadProgressSubject.stream;

  @override
  Stream<Duration> get positionStream => player.positionStream;

  @override
  Stream<Duration?> get durationStream => player.durationStream;

  @override
  Stream<PlayerState> get playerStateStream => player.playerStateStream;

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
    if (_lastFeed?.id == feed.id) {
      if (player.playerState.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
        await player.play();
      }
      return;
    }
    _currentIndexSubject.add(index);
    _lastFeed = feed;
    if(feed.url == null){
      return;
    }
    _currentPIndexSubject.add(null);

    _audioSource = LockCachingAudioSource(Uri.parse(feed.url!));
    await player.setAudioSource(_audioSource);
    _audioSource.downloadProgressStream.listen((event) {
      _downloadProgressSubject.add(event);
      if (event == 1.0) {
        player.play();
      }
    });
  }

  @override
  Future seekToParagraph(int index) async{
   super.seekToParagraph(index);
    _currentPIndexSubject.add(index);
  }

  @override
  Future<void> setLoopMode(FeedLoopMode mode) async {
    _loopMode = mode;
    switch (mode) {
      case FeedLoopMode.feed:
        await player.setLoopMode(LoopMode.one);
      case FeedLoopMode.paragraph:
      case FeedLoopMode.list:
      case FeedLoopMode.off:
        await player.setLoopMode(LoopMode.off);
    }
  }

  @override
  Future<void> pause() async{
    await player.pause();
  }

  @override
  Future<void> seekTo(Duration position) async{
    await player.seek(position);
  }

  @override
  Future<void> play() async{
    await player.play();
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
