import 'dart:convert';

enum Method { get, post, put, patch, delete, head }

/// 使用拓展枚举替代 switch判断取值
/// https://zhuanlan.zhihu.com/p/98545689
extension MethodExtension on Method {
  String get value => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'][index];
}

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

abstract interface class NetAdapter {
  Future<dynamic> request(Method method, String url,
      {Map<String, dynamic>? parameters, Map<String, dynamic>? header});

  Future<bool> download(String urlPath, String destination,
      {void Function(int received, int total)? progressCallback});
}

class CommonApiException implements Exception {
  final String message;
  final int code;

  CommonApiException(this.code, this.message);
}

class Api {}
