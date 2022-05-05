import 'package:dio/dio.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/update/index.dart';
import 'package:fil/utils/enum.dart';

class DeviceProvider {
  Dio client;
  static String appInfo = '/getAppInfo';
  static String action = '/device/action';
  static String operation = '/device/operation';
  static String register = '/device/register';
  static String registerId = '/jpush/registerId';
  static String registerAddress = '/jpush/registerAddress';
  static String deleteAddress = '/jpush/deleteAddress';
  static String addApp = '/error/addApp';
  static String baseUrl() {
    return GetBaseUrl();
  }

  DeviceProvider({Dio httpClient}) {
    client = httpClient ?? Dio();
    if (httpClient == null) {
      client.options.baseUrl = baseUrl();
      client.options.connectTimeout = Timeout.medium;
    }
  }

  Future<ApkInfo> getLatestApkInfo() async {
    try {
      var response = await client.get(appInfo);
      if (response.data['code'] == 0) {
        return ApkInfo.fromMap(response.data as Map<String, dynamic>);
      } else {
        return ApkInfo();
      }
    } catch (e) {
      return ApkInfo();
    }
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
    var response = await client.post(action, data: data);
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
    var response = await client.post(operation, data: data);
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
      var response = await client.post(register, data: data);
      if (response.data['code'] == 0) {
        print("register success");
      } else {
        print("error");
      }
    } catch (e) {
      print(e);
    }
  }
}
