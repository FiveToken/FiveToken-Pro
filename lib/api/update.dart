import 'package:fil/index.dart';

var apiMap = <String, String>{
  "dev": "http://192.168.19.127:9999",
  "test": "http://192.168.1.207:9999",
  "pro": "http://8.209.219.115:8090"
};
var mode = 'pro';

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

Future<ApkInfo> getApkInfoByVersion() async {
  try {
    var response = await Dio().get('${apiMap[mode]}/version',
        queryParameters: {'version': Global.version});
    if (response.data['code'] == 0) {
      return ApkInfo.fromMap(response.data['data']);
    } else {
      return ApkInfo();
    }
  } catch (e) {
    return ApkInfo();
  }
}

Future downloadFile(String urlPath, String savePath,
    {ProgressCallback onReceiveProgress}) async {
  var response = await Dio()
      .download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
  return response;
}

