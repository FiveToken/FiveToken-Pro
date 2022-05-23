import 'package:dio/dio.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/update/index.dart';

var apiMap = <String, String>{
  "dev": "http://192.168.19.127:9999",
  "test": "http://192.168.1.207:9999",
  "pro": "http://8.209.219.115:8090"
  // "pro": " https://api.fivetoken.io/"
};
var mode = 'pro';

/// get latest android apk info
Future<ApkInfo> getLatestApkInfo() async {
  try {
    var response = await Dio().get('${apiMap[mode]}/getAppInfo');
    if (response.data['code'] == 0) {
      return ApkInfo.fromMap(response.data as Map<String, dynamic>);
    } else {
      return ApkInfo();
    }
  } catch (e) {
    return ApkInfo();
  }
}

/// download a file by path
Future downloadFile(String urlPath, String savePath,
    {ProgressCallback onReceiveProgress}) async {
  var response = await Dio()
      .download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
  return response;
}

/// push action
void pushAction({String page, String type}) async {
  if (!Global.online) {
    return;
  }
  var data = <String, String>{
    "page": page,
    "type": type,
    "uuid": Global.uuid ?? "",
  };
  var response = await Dio().post('${apiMap[mode]}/device/action', data: data);
  if (response.data['code'] == 0) {
    print("push success");
  } else {
    print("push error");
  }
}

/// add operation by type
void addOperation(String type) async {
  if (!Global.online) {
    return;
  }
  var data = <String, String>{
    "type": type,
    "uuid": Global.uuid ?? "",
  };
  var response =
      await Dio().post('${apiMap[mode]}/device/operation', data: data);
  if (response.data['code'] == 0) {
    print("add op success");
  } else {
    print("add op error");
  }
}

/// register device
Future registerDevice() async {
  try {
    if (!Global.online) {
      return;
    }
    var data = <String, dynamic>{
      "platform": Global.platform,
      "uuid": Global.uuid ?? "",
      "os_version": Global.os,
      "app_version": Global.version
    };
    var response =
        await Dio().post('${apiMap[mode]}/device/register', data: data);
    if (response.data['code'] == 0) {
      print("register success");
    } else {
      print("error");
    }
  } catch (e) {
    print(e);
  }
}
