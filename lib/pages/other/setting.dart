import 'dart:io';
import 'package:fil/bloc/setting/setting_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/style/index.dart';
import 'package:fil/update/index.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_update_dialog/update_dialog.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:permission_handler/permission_handler.dart';

/// setting page
class SetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetPageState();
  }
}

/// page of setting
class SetPageState extends State<SetPage> {
  String get lang {
    return Global.langCode == 'zh' ? 'cn' : 'en';
  }

  ApkInfo apk = ApkInfo();
  File file;
  @override
  void initState() {
    super.initState();
    if (Global.online && mounted) {
      getLatestApkInfo();
    }
  }

  void install() async {
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

  getLatestApkInfo() async {
    var apk = await checkNeedUpdate();
    setState(() {
      this.apk = apk;
    });
  }

  void checkUpdate() async {
    var info = await checkNeedUpdate();
    if (info.needUpdate) {
      if (Platform.isIOS) {
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
          progressBackgroundColor: Color(0xff99ced3),
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
    return BlocProvider(
        create: (context) => SettingBloc()..add(initApkEvent()),
        child:
            BlocBuilder<SettingBloc, SettingState>(builder: (context, state) {
          return CommonScaffold(
            title: 'set'.tr,
            hasFooter: false,
            grey: true,
            body: Padding(
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TapCard(
                          items: [
                            CardItem(
                              label: 'addrBook'.tr,
                              onTap: () {
                                Get.toNamed('/addressBook/index');
                              },
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TapCard(
                          items: [
                            CardItem(
                              label: 'lang'.tr,
                              onTap: () {
                                Get.toNamed(langPage);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // TapCard(
                        //   items: [
                        //     CardItem(
                        //       label: 'notification'.tr,
                        //       onTap: () {
                        //         Get.toNamed(notificationPage);
                        //       },
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        TapCard(
                          items: [
                            CardItem(
                              label: 'about'.tr,
                              onTap: () {
                                Get.toNamed(aboutPage);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TapCard(
                          items: [
                            CardItem(
                              label: 'clearCache'.tr,
                              onTap: () async {
                                await OpenedBox.pushInsance
                                    .deleteAll(OpenedBox.pushInsance.keys);
                                await OpenedBox.messageInsance
                                    .deleteAll(OpenedBox.messageInsance.keys);
                                OpenedBox.multiProposeInstance.deleteAll(
                                    OpenedBox.multiProposeInstance.keys);
                                OpenedBox.multiApproveInstance.deleteAll(
                                    OpenedBox.multiApproveInstance.keys);
                                showCustomToast('opSucc'.tr);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TapCard(
                          items: [
                            CardItem(
                              label: 'service'.tr,
                              onTap: () {
                                var url =
                                    'https://fivetoken.co/private?lang=$lang';
                                goWebviewPage(url: url, title: 'service'.tr);
                              },
                            ),
                            CardItem(
                              label: 'clause'.tr,
                              onTap: () {
                                var url =
                                    'https://fivetoken.co/service?lang=$lang';
                                goWebviewPage(url: url, title: 'clause'.tr);
                              },
                            ),
                            CardItem(
                              label: 'latestVersion'.tr,
                              onTap: () {
                                checkUpdate();
                              },
                              append: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                        color: state.apk.needUpdate
                                            ? CustomColor.red
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                  ),
                                  CommonText(
                                    apk.version,
                                    color: CustomColor.grey,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
                  SafeArea(child: CommonText.grey(Global.version))
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            ),
          );
        }));
  }
}
