import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/dialog.dart';
/// create a multi-sig wallet
class MultiCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiCreatePageState();
  }
}

class MultiCreatePageState extends State<MultiCreatePage> {
  TextEditingController labelCtrl = TextEditingController();
  TextEditingController signerCtrl = TextEditingController();
  TextEditingController thresholdCtrl = TextEditingController();
  List<TextEditingController> signers = [TextEditingController()];
  var nonceBoxInstance = OpenedBox.nonceInsance;
  int singerNum = 0;
  int nonce;
  Gas chainGas = Gas();
  @override
  void initState() {
    super.initState();
    getGas();
    getWalletNonce();
    signerCtrl.text = singleStoreController.wal.address;
  }

  Future getGas() async {
    var res = await getGasDetail(to: Global.netPrefix + '01', method: 2);
    if (res.feeCap != '0') {
      singleStoreController.setGas(res);
      setState(() {
        this.chainGas = res;
      });
    }
  }

  void getWalletNonce() async {
    var wal = singleStoreController.wal;
    var nonce = await getNonce(wal);
    var address = wal.address;
    var now = DateTime.now().millisecondsSinceEpoch;
    if (nonce != -1) {
      this.nonce = nonce;
      if (!nonceBoxInstance.containsKey(address)) {
        nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
      } else {
        Nonce nonceInfo = nonceBoxInstance.get(address);
        var interval = 5 * 60 * 1000;
        if (now - nonceInfo.time > interval) {
          nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
        }
      }
    }
  }

  String get from {
    return singleStoreController.wal.addrWithNet;
  }

  int get realNonce {
    var cahcheNonce = nonceBoxInstance.get(from);
    var storeNonce = 0;
    if (cahcheNonce != null) {
      storeNonce = cahcheNonce.value;
    }
    var n = max(nonce, storeNonce);
    return n;
  }

  List<String> get signerAddrs {
    var signerAddrs = [from];
    signers.forEach((ctrl) {
      var s = ctrl.text.trim();
      signerAddrs.add(s);
    });
    return signerAddrs;
  }

  Future<TMessage> genMsg() async {
    var controller = singleStoreController;
    var value = '0';
    var threshold = int.parse(thresholdCtrl.text.trim());
    var params = {
      'signers': signerAddrs,
      'threshold': threshold,
      'unlock_duration': 0
    };
    /// serialize create params
    var p = await Flotus.genConstructorParamV3(jsonEncode(params));
    var decodeParams = jsonDecode(p);
    var msg = TMessage(
        version: 0,
        method: 2,
        nonce: realNonce,
        from: from,
        to: Global.netPrefix + '01',
        params: decodeParams['param'],
        value: value,
        gasFeeCap: controller.gas.value.feeCap,
        gasLimit: controller.gas.value.gasLimit,
        gasPremium: controller.gas.value.premium);
    return msg;
  }

  void pushMessage(String pass) async {
    var controller = singleStoreController;
    var threshold = int.parse(thresholdCtrl.text.trim());
    var msg = await genMsg();
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(msg));
    var wal = singleStoreController.wal;
    var ck = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    if (controller.wal.type == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var sm = SignedMessage(msg, Signature(signType, sign));
    String res = await pushSignedMsg(sm.toLotusSignedMessage());
    if (res != '') {
      controller.setGas(Gas());
      var now = getSecondSinceEpoch();
      OpenedBox.messageInsance.put(
          res,
          StoreMessage(
              pending: 1,
              from: from,
              to: msg.to,
              value: msg.value,
              owner: from,
              nonce: msg.nonce,
              signedCid: res,
              blockTime: getSecondSinceEpoch()));
      OpenedBox.multiInsance.put(
          res,
          MultiSignWallet(
              cid: res,
              blockTime: now,
              label: labelCtrl.text.trim(),
              threshold: threshold,
              signers: signerAddrs));
      var oldNonce = nonceBoxInstance.get(from);
      nonceBoxInstance.put(
          from, Nonce(value: realNonce + 1, time: oldNonce.time));
    }
    Get.offAllNamed(mainPage);
  }

  void handleConfirm() async {
    var label = labelCtrl.text.trim();
    var threshold = thresholdCtrl.text.trim();
    var thresholdNum = 0;
    if (label == '') {
      showCustomError('enterName'.tr);
      return;
    }
    try {
      var n = int.parse(threshold);
      thresholdNum = n;
    } catch (e) {
      showCustomError('errorThreshold'.tr);
      return;
    }
    if (thresholdNum > signers.length + 1) {
      showCustomError('bigThreshold'.tr);
      return;
    }
    var allAddrValid = true;
    for (var i = 0; i < signers.length; i++) {
      var addr = signers[i].text.trim();
      if (!isValidAddress(addr)) {
        allAddrValid = false;
        break;
      }
    }
    if (!allAddrValid) {
      showCustomError('errorSigner'.tr);
      return;
    }
    if (singleStoreController.gas.value.feeCap == '0') {
      await getGas();
      if (singleStoreController.gas.value.feeCap == '0') {
        showCustomError("error.wrongGas");
        return;
      }
    }
    //var a = double.parse(_amountCtl.text.trim());
    if (nonce == null || nonce == -1) {
      showCustomError('errorGetNonce'.tr);
      return;
    }
    if (singleStoreController.wal.readonly == 1) {
      var msg = await genMsg();
      singleStoreController.setPushBackPage(mainPage);
      var cid = await Flotus.genCid(msg: jsonEncode(msg));
      Get.toNamed(mesBodyPage, arguments: {'mes': msg});
      
      OpenedBox.multiInsance.put(
          cid,
          MultiSignWallet(
              cid: cid,
              blockTime: getSecondSinceEpoch(),
              label: labelCtrl.text.trim(),
              threshold: int.parse(thresholdCtrl.text.trim()),
              signers: signerAddrs));
    } else {
      showPassDialog(context, (String pass) {
        pushMessage(pass);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'createMulti'.tr,
      footerText: 'create'.tr,
      onPressed: () {
        handleConfirm();
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12),
        physics: BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 10,
          ),
          Field(
            controller: labelCtrl,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            label: 'nameMulti'.tr,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: CommonText(
              'addMultiMember'.tr,
              size: 14,
              weight: FontWeight.w500,
            ),
          ),
          CommonCard(Container(
            height: 45,
            padding: EdgeInsets.fromLTRB(12, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(dotString(str: singleStoreController.wal.address)),
                CommonText('(${'myAddr'.tr})')
              ],
            ),
          )),
          SizedBox(
            height: 5,
          ),
          Column(
            children: List.generate(signers.length, (index) {
              return Container(
                child: Field(
                    controller: signers[index],
                    extra: Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Get.toNamed(scanPage,
                                      arguments: {'scene': ScanScene.Address})
                                  .then((scanResult) {
                                if (scanResult != '' &&
                                    isValidAddress(scanResult)) {
                                  signers[index].text = scanResult;
                                }
                              });
                            },
                            child: Image(
                              width: 16,
                              image: AssetImage('images/scan.png'),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          child: IconMinus,
                          onTap: () {
                            signers.removeAt(index);
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 12,
                        )
                      ],
                    )),
              );
            }),
          ),
          SizedBox(
            height: 5,
          ),
          FButton(
            text: 'addMember'.tr,
            width: double.infinity,
            height: 50,
            corner: FCorner.all(6),
            color: Colors.white,
            onPressed: () {
              signers.add(TextEditingController());
              setState(() {});
            },
            image: Icon(Icons.add),
          ),
          SizedBox(
            height: 13,
          ),
          Field(
            label: 'approvalNum'.tr,
            hintText: 'lessThanMember'.tr,
            type: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: thresholdCtrl,
          ),
          SizedBox(
            height: 15,
          ),
          Obx(() => SetGas(
                maxFee: singleStoreController.maxFee,
                gas: chainGas,
              )),
          SizedBox(
            height: 100,
          )
        ]),
      ),
    );
  }
}
