import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathUtil{

  ///获取手机的存储目录路径
  ///getExternalStorageDirectory() 获取的是 android 的外部存储 （External Storage）
  ///getApplicationDocumentsDirectory 获取的是 ios 的Documents` or `Downloads` 目录
  static Future<String?> getLocalStoragePath() async {
    late Directory? directory;
    if(Platform.isAndroid){
      directory = await getExternalStorageDirectory();
    }else if(Platform.isIOS || Platform.isMacOS){
      directory = await getApplicationDocumentsDirectory();
    }else{
      return null;
    }
    return directory?.path;
  }

  static Future<String?> getTemporaryPath() async {
    Directory directory = await getTemporaryDirectory();
    return directory.path;
  }
}