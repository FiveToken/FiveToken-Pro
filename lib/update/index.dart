import 'package:fil/index.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:install_plugin/install_plugin.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';

typedef OnReceiveProgress(int count, int total);
typedef OnFinished();
UpdateDialog dialog;

class ApkInfo {
  String version, name, content, downloadUrl, hash;
  int size;
  bool force, needUpdate, checkHash;
  ApkInfo(
      {this.version,
      this.name,
      this.content,
      this.downloadUrl,
      this.size,
      this.force,
      this.checkHash,
      this.hash,
      this.needUpdate});
  ApkInfo.fromMap(Map<String, dynamic> map) {
    version = map['version'];
    name = map['name'];
    content = map['content'];
    downloadUrl = map['downloadUrl'];
    size = map['size'];
    force = map['force'];
    hash = map['hash'];
    checkHash = map['check_hash'];
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
  var apkInfo = await getLatestApkInfo();
  if (apkInfo != null && apkInfo.version != info.version) {
    apkInfo.needUpdate = true;
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
        title:
            'updateTips'.tr.replaceFirst(RegExp('{version}'), info.version),
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
  Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
    InstallPlugin.installApk(file.path, 'io.fivetokenpro.fil').then((result) {
      print('install apk $result');
    }).catchError((error) {
      print('install apk error: $error');
    });
  } else {
    print('Permission request fail!');
  }
}
