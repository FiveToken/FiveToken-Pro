import 'package:fil/api/update.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

/// import miner address
class MinerPage extends StatefulWidget {
  @override
  State createState() => MinerPageState();
}

/// page of miner
class MinerPageState extends State<MinerPage> {
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController labelCtrl = TextEditingController();
  void handleSubmit() async {
    var address = addressCtrl.text.trim();
    var label = labelCtrl.text.trim();
    if (address.substring(0, 2) != Global.netPrefix + '0' ||
        address.length > 10) {
      showCustomError('errorAddr'.tr);
      return;
    }
    if (label == '' || label.length > 20) {
      showCustomError('enterName'.tr);
      return;
    }

    var exist = OpenedBox.addressInsance.containsKey(address);
    if (exist) {
      showCustomError('errorExist'.tr);
      return;
    }
    try {
      showCustomLoading('Loading');
      var type = await Global.provider.getAddressType(address);
      dismissAllToast();
      if (type != FilecoinAddressType.miner) {
        showCustomError('minerNotExist'.tr);
        return;
      }
      Wallet activeWallet = Wallet(
          ck: '',
          address: address,
          label: label,
          count: 0,
          readonly: 1,
          walletType: WalletsType.miner,
          type: address[1]);
      OpenedBox.addressInsance.put(address, activeWallet);
      Global.store.setString('activeWalletAddress', address);
      addOperation('add_miner');
      $store.setWallet(activeWallet);
      Get.offAllNamed(mainPage);
    } catch (e) {
      showCustomError('minerNotExist'.tr);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'importMiner'.tr,
      footerText: 'sure'.tr,
      grey: true,
      onPressed: handleSubmit,
      actions: [
        Padding(
          child: GestureDetector(
              onTap: () {
                Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
                    .then((scanResult) {
                  if (scanResult != '') {
                    addressCtrl.text = scanResult as String;
                  }
                });
              },
              child: Image(
                width: 20,
                image: AssetImage('images/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      body: Padding(
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Field(
              controller: addressCtrl,
              label: 'walletAddress'.tr,
              append: GestureDetector(
                child: Image(width: 20, image: AssetImage('images/cop.png')),
                onTap: () async {
                  var data = await Clipboard.getData(Clipboard.kTextPlain);
                  addressCtrl.text = data.text;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Field(
              controller: labelCtrl,
              label: 'walletName'.tr,
            ),
            SizedBox(
              height: 10,
            ),
          ]),
          padding: EdgeInsets.symmetric(horizontal: 20)),
    );
  }
}
