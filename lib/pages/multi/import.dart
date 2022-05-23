import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/button.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/other.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// import a multi-sig wallet of a signer
class MultiImportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiImportPageState();
  }
}

/// page of multi import
class MultiImportPageState extends State<MultiImportPage> {
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  var box = OpenedBox.multiInsance;
  var l = OpenedBox.multiInsance != null
      ? OpenedBox.multiInsance.values.where((wal) {
          if (wal.signers != null) {
            return wal.signers.contains($store.wal.addressWithNet);
          }
          return false;
        }).toList()
      : [];
  void handleImport() async {
    var label = labelCtrl.text.trim();
    var addr = addressCtrl.text.trim();
    if (label == '') {
      showCustomError('enterName'.tr);
      return;
    }
    if (addr == '') {
      showCustomError('enterAddr'.tr);
      return;
    }
    if (!isMultiAddr(addr)) {
      showCustomError('errorAddr'.tr);
      return;
    }
    if (box.containsKey(addr) && l.length > 0) {
      showCustomError('errMultiExist'.tr);
      return;
    }
    showCustomLoading('Loading');
    try {
      var res = await Global.provider.getMultiInfo(addr);
      print(res);
      var signer = $store.addr;
      var signers = res.signerMap.keys.toList();
      if (!signers.contains(Global.netPrefix + signer.substring(1))) {
        showCustomError('notSigner'.tr);
      } else {
        var wallet = MultiSignWallet(
            label: label,
            id: addr,
            owner: signer,
            blockTime: getSecondSinceEpoch(),
            status: 1,
            signerMap: res.signerMap,
            signers: signers,
            robustAddress: res.robustAddress,
            threshold: res.approveRequired as int,
            balance: res.balance);
        OpenedBox.multiInsance.put(addr, wallet);
        showCustomToast('importSuccess'.tr);
        addOperation('import_multisig');
        $store.setMultiWallet(wallet);
        Global.store.setString('activeMultiAddress', wallet.addressWithNet);
        Get.offAndToNamed(multiMainPage);
      }
    } catch (e) {
      showCustomError('searchFailed'.tr);
    }
  }

  bool isMultiAddr(String addr) {
    return addr[1] == '0' && addr.length < 12;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'importMulti'.tr,
      footerText: 'import'.tr,
      actions: [
        ScanAction(handleScan: () {
          Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
              .then((scanResult) {
            if (scanResult != '') {
              if (!isMultiAddr(scanResult as String)) {
                showCustomError('wrongAddr'.tr);
              }
              addressCtrl.text = scanResult as String;
            }
          });
        })
      ],
      onPressed: () {
        handleImport();
      },
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
              label: 'multiAddr'.tr,
              hintText: 'enterMultiAddr'.tr,
            ),
            Field(
              controller: labelCtrl,
              label: 'multiTag'.tr,
            ),
            SizedBox(height: 20),
            DocButton(
              page: multiImportPage,
            )
          ]),
          padding: EdgeInsets.symmetric(horizontal: 20)),
    );
  }
}
