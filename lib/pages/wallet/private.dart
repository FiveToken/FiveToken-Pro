import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/pages/wallet/mne.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenshot_events/flutter_screenshot_events.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// display private key of the wallet
class WalletPrivatekeyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletPrivatekeyPageState();
  }
}

/// page of wallet privatekey
class WalletPrivatekeyPageState extends State<WalletPrivatekeyPage> {
  int index = 0;
  bool showCode = false;
  String pk = Get.arguments['pk'] as String;
  String _message = "";

  @override
  void initState() {
    super.initState();
    if (mounted) {
      FlutterScreenshotEvents.disableScreenshots(true);
      FlutterScreenshotEvents.statusStream?.listen((event) {
        setState(() {
          _message = event.toString();
          showCustomToast(_message);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var ck = base64ToHex(pk, Global.cacheWallet.type);
    return CommonScaffold(
      title: 'exportPk'.tr,
      footerText: 'cancel'.tr,
      onPressed: () {
        Get.back();
      },
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TabItem(
                active: index == 0,
                label: 'pk'.tr,
                onTap: () {},
              )),
            ],
          ),
          KeyString(
            data: ck,
          )
        ],
      ),
    );
  }
}
