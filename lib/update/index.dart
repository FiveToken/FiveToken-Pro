import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/style/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnReceiveProgress = Function(int count, int total);
typedef OnFinished = Function();
UpdateDialog dialog;

class ApkInfo {
  String version, name, content, downloadUrl, hash;
  int size;
  bool force, needUpdate, checkHash;
  ApkInfo(
      {this.version = '',
      this.name = '',
      this.content = '',
      this.downloadUrl = '',
      this.size,
      this.force,
      this.checkHash,
      this.hash,
      this.needUpdate = false});
  ApkInfo.fromMap(Map<String, dynamic> map) {
    version = map['version'] as String;
    name = map['name'] as String;
    content = map['content'] as String;
    downloadUrl = map['downloadUrl'] as String;
    size = map['size'] as int;
    force = map['force'] as bool;
    hash = map['hash'] as String;
    checkHash = map['check_hash'] as bool;
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'name': name,
      'size': size,
      'content': content,
      'downloadUrl': downloadUrl,
      'force': force,
      'needUpdate': needUpdate,
      'hash': hash,
      'checkHash': checkHash
    };
  }
}

Future<ApkInfo> checkNeedUpdate() async {
  PackageInfo info = await PackageInfo.fromPlatform();
  print(info);
  var apkInfo = await getLatestApkInfo();
  if (apkInfo != null && apkInfo.version != info.version) {
    var latestV = int.tryParse(apkInfo.version.split('.').join()) ?? 0;
    var pkgV = int.tryParse(info.version.split('.').join()) ?? 0;
    if (latestV > pkgV) {
      apkInfo.needUpdate = true;
    } else {
      apkInfo.needUpdate = false;
    }

    return apkInfo;
  } else {
    apkInfo.needUpdate = false;
    return apkInfo;
  }
}

void downLoadApk(String downloadUrl, String savePath,
    {OnReceiveProgress onReceiveProgress, Noop onFinished}) {
  downloadFile(downloadUrl, savePath, onReceiveProgress: onReceiveProgress)
      .then((value) {
    onFinished();
  });
}

Future<String> getDownloadDirPath() async {
  Directory directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return directory.path;
}

void checkUpdate(BuildContext context) async {
  File file;
  var info = await checkNeedUpdate();
  if (info.needUpdate) {
    var ignoreVersion = Global.store.getString('ignore_version');
    if (ignoreVersion != null && ignoreVersion == info.version) {
      return;
    }
    var dirPath = await getDownloadDirPath();
    file = File('$dirPath/${info.name}--${info.version}.apk');
    info.content = info.content.replaceAll('\\n', '\n');
    var fileExist = file.existsSync();
    dialog = UpdateDialog.showUpdate(context,
        title: 'updateTips'.tr.replaceFirst(RegExp('{version}'), info.version),
        themeColor: Color(FColorBlue),
        updateContent: "${info.content}",
        progressBackgroundColor: Color(0xff5CC1CB),
        isForce: info.force,
        width: 280,
        topImage: Image.asset('images/update.png'),
        updateButtonText: fileExist ? 'updateInstall'.tr : 'updateTitle'.tr,
        enableIgnore: !info.force,
        onIgnore: () {
          Global.store.setString('ignore_version', info.version);
          dialog.dismiss();
        },
        ignoreButtonText: 'updateIgnore'.tr,
        onUpdate: () {
          if (Platform.isIOS) {
            openInBrowser('https://testflight.apple.com/join/wG5UVUbI');
            return;
          }
          if (fileExist) {
            install(file);
          } else {
            downLoadApk(info.downloadUrl, file.path,
                onReceiveProgress: (int count, int total) {
              var progress = count / total;
              dialog.update(progress);
            }, onFinished: () {
              dialog.dismiss();
              install(file);
            });
          }
        });
  }
}

void install(File file) async {
  if (!file.existsSync()) {
    return;
  }
  var permissions = await Permission.storage.status;
  if (permissions.isGranted) {
    InstallPlugin.installApk(file.path, 'io.forcewallet.fil').then((result) {
      print('install apk $result');
    }).catchError((error) {
      print('install apk error: $error');
    });
  } else {
    print('Permission request fail!');
  }
}
