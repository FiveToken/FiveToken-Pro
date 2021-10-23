
import 'package:fil/index.dart';
/// import a multi-sig wallet of a signer
class MultiImportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiImportPageState();
  }
}

class MultiImportPageState extends State<MultiImportPage> {
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  var box=OpenedBox.multiInsance;
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
    if(box.containsKey(addr)){
      showCustomError('errMultiExist'.tr);
      return;
    }
    showCustomLoading('Loading');
    try {
      var res = await Global.provider.getMultiInfo(addr);
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
            threshold: res.approveRequired,
            balance: res.balance);
        OpenedBox.multiInsance.put(addr, wallet);
        showCustomToast('importSuccess'.tr);
        $store.setMultiWallet(wallet);
        Global.store.setString('activeMultiAddress', wallet.addrWithNet);
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
              if (!isMultiAddr(scanResult)) {
                showCustomError('wrongAddr'.tr);
              }
              addressCtrl.text = scanResult;
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
            SizedBox(
              height: 20
            ),
            DocButton(
              page: multiImportPage,
            )
          ]),
          padding: EdgeInsets.symmetric(horizontal: 20)),
    );
  }
}
