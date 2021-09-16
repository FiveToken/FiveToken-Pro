import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

/// import miner address
class MinerPage extends StatefulWidget {
  @override
  State createState() => MinerPageState();
}

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
    showCustomLoading('Loading');
    var actor = await getAddressActor(address);
    dismissAllToast();
    if (actor == '') {
      showCustomError('minerNotExist'.tr);
    } else {
      Wallet activeWallet = Wallet(
          ck: '',
          address: address,
          label: label,
          count: 0,
          readonly: 1,
          walletType: 2,
          type: address[1]);
      OpenedBox.addressInsance.put(address, activeWallet);
      $store.setWallet(activeWallet);
      Global.store.setString('activeWalletAddress', address);
      Get.offAllNamed(mainPage);
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
                    addressCtrl.text = scanResult;
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
              label: 'walletAddr'.tr,
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
