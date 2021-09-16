import 'package:fil/index.dart';

var apiMap = <String, String>{
  "dev": "http://192.168.19.127:9999",
  "test": "http://192.168.1.207:9999",
  "pro": "http://8.209.219.115:8090"
};
var mode = 'pro';

/// get latest android apk info
Future<ApkInfo> getLatestApkInfo() async {
  try {
    var response = await Dio().get('${apiMap[mode]}/getAppInfo');
    if (response.data['code'] == 0) {
      return ApkInfo.fromMap(response.data);
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

