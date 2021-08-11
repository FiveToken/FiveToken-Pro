import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
/// import readonly wallet
class ReadonlyPage extends StatefulWidget {
  @override
  State createState() => ReadonlyPageState();
}

class ReadonlyPageState extends State<ReadonlyPage> {
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  void handleSubmit() {
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
        walletType: 0,
        type: address[1]);
    OpenedBox.addressInsance.put(address, activeWallet);
    singleStoreController.setWallet(activeWallet);
    Global.store.setString('activeWalletAddress', address);
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
              label: 'walletAddr'.tr,
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
