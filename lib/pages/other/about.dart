import 'package:fil/index.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';
import 'dart:io';
import 'package:install_plugin/install_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

const _textStyle = TextStyle(
  fontSize: 15,
  color: Color(FColorBlue),
);
/// display something about app
class AboutPage extends StatefulWidget {
  @override
  State createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  double _gapHeight = 10;
  UpdateDialog dialog;
  File file;
  bool isAndroid = Platform.isAndroid;
  ApkInfo apk = ApkInfo();
  Widget _divider = Divider(
    color: Color(FTips3),
    height: 0.5,
    indent: 15,
    endIndent: 15,
  );
  @override
  void initState() {
    super.initState();
    if (Global.online && Platform.isAndroid) {
      getLatestApkInfo();
    }
  }

  void install() async {
    if (!file.existsSync()) {
      return;
    }
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      InstallPlugin.installApk(file.path, 'io.forcewallet.fil').then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    } else {
      print('Permission request fail!');
    }
  }

  getLatestApkInfo() async {
    var info = await checkNeedUpdate();
    setState(() {
      apk = info;
    });
  }

  void checkUpdate() async {
    var info = await checkNeedUpdate();
    if (info.needUpdate) {
      var dirPath = await getDownloadDirPath();
      file = File('$dirPath/${info.name}--${info.version}.apk');
      info.content = info.content.replaceAll('\\n', '\n');
      var fileExist = file.existsSync();
      dialog = UpdateDialog.showUpdate(context,
          title: 'updateTips'.tr
              .replaceFirst(RegExp('{version}'), info.version),
          themeColor: Color(FColorBlue),
          updateContent: "${info.content}",
          progressBackgroundColor: Color(0xff5CC1CB),
          isForce: info.force,
          width: 280,
          topImage: Image.asset('images/update.png'),
          updateButtonText: fileExist ? 'updateInstall'.tr : 'updateTitle'.tr,
          enableIgnore: true,
          onIgnore: () {
            dialog.dismiss();
          },
          ignoreButtonText: 'updateIgnore'.tr,
          onUpdate: () {
            if (fileExist) {
              install();
            } else {
              downLoadApk(info.downloadUrl, file.path,
                  onReceiveProgress: (int count, int total) {
                var progress = count / total;
                dialog.update(progress);
              }, onFinished: () {
                dialog.dismiss();
                install();
              });
            }
          });
    } else {
      showCustomToast('isLatest'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(FColorWhite),
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Color(FColorWhite),
          elevation: NavElevation,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: IconNavBack,
            alignment: NavLeadingAlign,
          ),
          title: Text(
            'about'.tr,
            style: NavTitleStyle,
          ),
          centerTitle: true,
        ),
        preferredSize: Size.fromHeight(NavHeight),
      ),
      body: ListView(
        children: <Widget>[
          Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("images/ic_launcher.png"),
                    width: 100,
                  ),
                  Text('FiveToken Pro',
                      style: TextStyle(fontSize: 20, color: Color(FTips1))),
                  SizedBox(
                    height: _gapHeight,
                  ),
                  Text(Global.version,
                      style: TextStyle(fontSize: 13, color: Color(FTips2)))
                ],
              )),
          Container(
              child: Column(
            children: <Widget>[
              ListTile(
                onTap: () {
                  openInBrowser("https://fivetoken.io");
                },
                title: Row(
                  children: <Widget>[
                    Text('aboutWeb'.tr, style: ListLabelStyle),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Text("https://fivetoken.io", style: _textStyle)
                  ],
                ),
              ),
              _divider,
              ListTile(
                onTap: () {
                  openInBrowser("https://filscan.io");
                },
                title: Row(
                  children: <Widget>[
                    Text('aboutData'.tr, style: ListLabelStyle),
                    Spacer(),
                    Text("https://filscan.io", style: _textStyle)
                  ],
                ),
              ),
              _divider,
              ListTile(
                title: Row(
                  children: <Widget>[
                    Text('wechat'.tr, style: ListLabelStyle),
                    Expanded(
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      onTap: () {
                        copyText('FilecoinWallet001');
                        showCustomToast('copySucc'.tr);
                      },
                      child: Row(
                        children: [
                          IconCopy2,
                          SizedBox(
                            width: 5,
                          ),
                          Text('FilecoinWallet001',
                              style:
                                  TextStyle(fontSize: 15, color: Color(FTips2)))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _divider,
              isAndroid
                  ? Column(
                      children: [
                        ListTile(
                          onTap: () {
                            checkUpdate();
                          },
                          title: Row(
                            children: [
                              Text('updateCheck'.tr),
                              Spacer(),
                              Global.online
                                  ? Text(
                                      '${'latestVersion'.tr} ${apk.version}',
                                      style: _textStyle,
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                        _divider
                      ],
                    )
                  : Container(),
            ],
          ))
        ],
      ),
    );
  }
}
