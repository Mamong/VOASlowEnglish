//缓存策略：
//1.存储记录进行查询：使用数据库等可查询的存储。风险是数据字段不全，无法进行排序，需要自己加字段进行排序；需要补充查询值的字段。需要专门处理。
//2.存储请求和JSON：使用文件或数据库等存储，在拦截器层面实现，相对简单
//3.存储请求（参数较多）和cache model：使用local storage存取，可以有更灵活的控制。需要使用hive这种支持自定义类型的存储。
import 'package:key_value_storage/key_value_storage.dart';

class FeedLocalStorage{

  FeedLocalStorage({
    required this.noSqlStorage,
  });

  final KeyValueStorage noSqlStorage;

  Future<void> upsertBookedPublishers(List<String> publishers) async {
    final box = await noSqlStorage.bookedPublishersBox;
    await box.put(0, publishers);
  }

  Future<List<String>?> getBookedPublishers() async {
    final box = await noSqlStorage.bookedPublishersBox;
    return box.get(0);
  }
}