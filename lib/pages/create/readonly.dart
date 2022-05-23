import 'package:fil/api/update.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
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

/// import readonly wallet
class ReadonlyPage extends StatefulWidget {
  @override
  State createState() => ReadonlyPageState();
}

/// page of readonly wallet
class ReadonlyPageState extends State<ReadonlyPage> {
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  void handleSubmit() async {
    var label = labelCtrl.text;
    var address = addressCtrl.text.trim();
    if (label == '') {
      showCustomError('enterName'.tr);
      return;
    }
    if (!isValidAddress(address) || address[1] == '0') {
      showCustomError('errorAddr'.tr);
      return;
    }
    try {
      showCustomLoading('Loading');
      var type = await Global.provider.getAddressType(address);
      dismissAllToast();
      if (type != FilecoinAddressType.account) {
        showCustomError('errorAddr'.tr);
        return;
      }
    } catch (e) {
      showCustomError('searchAccountFail'.tr);
      return;
    }
    var exist = OpenedBox.addressInsance.containsKey(address);
    if (exist) {
      showCustomError('errorExist'.tr);
      return;
    }
    Wallet activeWallet = Wallet(
        ck: '',
        address: address,
        label: label,
        count: 0,
        readonly: 1,
        walletType: WalletsType.normal,
        type: address[1]);
    OpenedBox.addressInsance.put(address, activeWallet);
    Global.store.setString('activeWalletAddress', address);
    addOperation('add_readonly');
    $store.setWallet(activeWallet);
    Get.offAllNamed(mainPage);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'addReadonly'.tr,
      footerText: 'import'.tr,
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
      onPressed: handleSubmit,
      body: Padding(
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Field(
              controller: addressCtrl,
              append: GestureDetector(
                child: Image(width: 20, image: AssetImage('images/cop.png')),
                onTap: () async {
                  var data = await Clipboard.getData(Clipboard.kTextPlain);
                  addressCtrl.text = data.text;
                },
              ),
              label: 'walletAddress'.tr,
            ),
            SizedBox(
              height: 10,
            ),
            Field(
              controller: labelCtrl,
              label: 'walletName'.tr,
            ),
          ]),
          padding: EdgeInsets.symmetric(horizontal: 20)),
    );
  }
}
