

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dio_interceptor.dart';
import 'net_adapter.dart';


/// 默认dio配置
Duration _connectTimeout = const Duration(seconds: 15);
Duration _receiveTimeout = const Duration(seconds: 15);
Duration _sendTimeout = const Duration(seconds: 10);
String _baseUrl = 'http://engcorner.cn';
List<Interceptor> _interceptors = [LoggingInterceptor()];

class DioAdapter implements NetAdapter{

  factory DioAdapter() => _singleton;

  DioAdapter._() {

    final BaseOptions options = BaseOptions(
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      /// dio默认json解析，这里指定返回UTF8字符串，自己处理解析。（可也以自定义Transformer实现）
      responseType: ResponseType.plain,
      validateStatus: (_) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: _baseUrl,
//      contentType: Headers.formUrlEncodedContentType, // 适用于post form表单提交
    );
    _dio = Dio(options);
    /// Fiddler抓包代理配置 https://www.jianshu.com/p/d831b1f7c45b
    // _dio.httpClientAdapter = IOHttpClientAdapter()..onHttpClientCreate = (HttpClient client) {
    //   client.findProxy = (uri) {
    //     //proxy all request to localhost:8888
    //     return 'PROXY 10.41.0.132:8888';
    //   };
    //   return client;
    // };

    /// 添加拦截器
    void addInterceptor(Interceptor interceptor) {
      _dio.interceptors.add(interceptor);
    }
    _interceptors.forEach(addInterceptor);
  }

  static final DioAdapter _singleton = DioAdapter._();

  static DioAdapter get instance => DioAdapter();

  static late Dio _dio;

  Dio get dio => _dio;

  @override
  Future<dynamic> request(Method method, String url, {
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? header
  }) async {
    //request
    Options options = Options(method: method.value, headers: header);
    try {
      final Response<String> response = await _dio.request<String>(
          url,
          data: method == Method.get ? null : parameters,
          queryParameters: method == Method.get ? parameters : null,
          options: options
      );

      final String data = response.data.toString();
      /// 集成测试无法使用 isolate https://github.com/flutter/flutter/issues/24703
      /// 使用compute条件：数据大于10KB（粗略使用10 * 1024）且当前不是集成测试（后面可能会根据Web环境进行调整）
      /// 主要目的减少不必要的性能开销
      final bool isCompute = data.length > 10 * 1024;
      return json.decode(data);
      // final Map<String, dynamic> map = isCompute ? await compute(parseData, data) : parseData(data);
      // final Map<String, dynamic> status = map["status"];
      // final int code = status["code"];
      // final String message = status["message"];
      // if(code != 1000){
      //   if(code == 1001){
      //     GlobalContext.navigatorKey.currentState!.pushNamed("/login");
      //     return;
      //   }
      //   throw CommonApiException(code, message);
      // }
      // dynamic result = map["result"];
      // return result;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        throw CommonApiException(e.response?.statusCode ?? 1006, e.message ?? "");
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        throw CommonApiException(1006, e.message ?? "");
      }
    } on FormatException {
      throw CommonApiException(1006,"数据解析错误");
    }
  }


  ///PermissionGroup.storage 对应的是
  ///android 的外部存储 （External Storage）
  ///ios 的Documents` or `Downloads`
  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      ///安卓平台中 checkPermissionStatus方法校验是否有储存卡的读写权限
      bool status = await Permission.storage.isGranted;
      if (!status) {
        ///无权限那么 调用方法 requestPermissions 申请权限
        return await Permission.storage.request().isGranted;
      }
    }
    return true;
  }

  @override
  Future<bool> download(
      String urlPath,
      String destination,
      {void Function(int received, int total)? progressCallback}) async {
    bool status = await checkStoragePermission();
    //判断如果还没拥有读写权限就申请获取权限
    if (!status) {
      return false;
    }
    // 调用下载方法 --------做该做的事
    // String? savePath = await PathUtil.getLocalStoragePath();
    // String? tempPath = await PathUtil.getTemporaryPath();
    //
    // if(savePath == null || tempPath == null){
    //   return;
    // }
    // final directory = Directory('$savePath/ydwordbooks');
    // if (!directory.existsSync()) {
    //   directory.createSync();
    // }

    try {
      Response response =
          await dio.download(urlPath, destination, onReceiveProgress: progressCallback);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('下载请求成功');
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
       print('ERROR:======>$e');
       return false;
    }
  }

}