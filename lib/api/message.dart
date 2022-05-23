import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';

///collect app run error
void addAppError(String err) async {
  Map<String, String> data = {
    "platform": Platform.operatingSystem,
    "uuid": Global.uuid ?? "",
    "os_version": Global.os,
    "app_version": Global.version,
    "err_msg": err
  };
  var response = await Dio().post('${apiMap[mode]}/error/addApp', data: data);
  if (response.data['code'] == 0) {
    print('add error success');
  } else {
    print('add error fail');
  }
}
