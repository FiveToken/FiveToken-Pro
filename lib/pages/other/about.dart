import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/style/index.dart';
import 'package:fil/widgets/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

const _textStyle = TextStyle(
  fontSize: 15,
  color: Color(FColorBlue),
);

/// display something about app
class AboutPage extends StatelessWidget {
  final double _gapHeight = 10;
  final Widget _divider = Divider(
    color: Color(FTips3),
    height: 0.5,
    indent: 15,
    endIndent: 15,
  );

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
                  goWebviewPage(
                      url: "https://fivetoken.co", title: 'Fivetoken');
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
                  goWebviewPage(url: "https://m.filscan.io", title: 'Filscan');
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
            ],
          ))
        ],
      ),
    );
  }
}
