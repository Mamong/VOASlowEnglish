import 'package:domain_models/domain_models.dart';
import 'package:just_audio/just_audio.dart';

enum FeedLoopMode { off, feed, paragraph, list }

extension LoopModeName on FeedLoopMode {
  String get name => ["无", "单篇", "单句", "列表"][index];
}

///提供音视频播放器统一接口
abstract class MediaPlayer{

  Stream<int?> get currentIndexStream;
  int? get currentIndex;

  Stream<int?> get currentParagraphIndexStream;
  int? get currentParagraphIndex;

  Stream<double> get downloadProgressStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlayerState> get playerStateStream;

  Future<void> seekTo(Duration position);
  Future<void> play();
  Future<void> pause();
  Future<void> setLoopMode(FeedLoopMode mode);

  Future<void> playAt(int index);

  Feed? get currentFeed =>
      currentIndex == null ? null : playList?[currentIndex!];

  List<Feed>? get playList;

  FeedLoopMode get loopMode;

  Future<void> playFeed(Feed feed) async {
    if (playList == null) return;
    int index = playList!.indexWhere((element) => element.id==feed.id);
    await playAt(index);
  }

  Future<void> tangleLoopMode() async {
    int next = (loopMode.index + 1) % FeedLoopMode.values.length;
    await setLoopMode(FeedLoopMode.values[next]);
  }

  Future seekToParagraph(int index) async{
    if (currentFeed == null) return;
    Map<String, String> cation = currentFeed!.captions[index];
    String start = cation["start"]!;
    Duration startDuration = start.toDuration();
    await seekTo(startDuration);
  }


}