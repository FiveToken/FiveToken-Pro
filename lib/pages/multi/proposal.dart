import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/dialog.dart';

class MultiProposalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiProposalPageState();
  }
}

class MultiProposalPageState extends State<MultiProposalPage> {
  final TextEditingController toCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();
  final TextEditingController ownerCtrl = TextEditingController();
  MultiSignWallet wallet = singleStoreController.multiWal;
  var nonceBoxInstance = OpenedBox.nonceInsance;
  String methodId = '0';
  int nonce;
  bool toIsMiner = false;
  TextEditingController worker = TextEditingController();
  List<TextEditingController> controllers = [TextEditingController()];
  Gas chainGas = Gas();
  bool get isChangeOwner {
    return methodId == '23';
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '' && isValidAddress(scanResult)) {
        toCtrl.text = scanResult;
      }
    });
  }

  void addController() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void removeController(int index) {
    setState(() {
      controllers.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    getGas();
    getWalletNonce();
  }

  Future getGas() async {
    var res = await getGasDetail(to: wallet.id, method: 2);
    if (res.feeCap != '0') {
      singleStoreController.setGas(res);
      setState(() {
        this.chainGas = res;
      });
    }
  }

  Future<String> getParamsByMethod(String to, String value) async {
    String params = '';
    String newOwner = ownerCtrl.text.trim();
    switch (methodId) {
      case '0':
        params = await Flotus.genProposeForSendParamV3(to, value);
        break;
      case '3':
        params = await Flotus.genProposalForChangeWorkerAddress(
            to,
            jsonEncode({
              "new_worker": worker.text,
              "new_control_addrs":
                  controllers.map((ctrl) => ctrl.text.trim()).toList()
            }));
        break;
      case '16':
        params = await Flotus.genProposalForWithdrawBalanceV3(to, value);
        break;
      case '23':
        params = await Flotus.genProposalForChangeOwnerV3(newOwner, to, value);
        break;
      default:
    }
    return params;
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

  void handleConfirm() async {
    var to = toCtrl.text.trim();
    var value = valueCtrl.text.trim();
    var feeCap = singleStoreController.gas.value.feeCap;
    var gasLimit = singleStoreController.gas.value.gasLimit;

    if (to == '') {
      showCustomError('enterAddr'.tr);
      return;
    }
    if (!isValidAddress(to)) {
      showCustomError('errorAddr'.tr);
    }

    try {
      double.parse(value);
    } catch (e) {
      showCustomError('enterValidAmount'.tr);
      return;
    }
    var balance = double.parse(wallet.balance);
    var amountAtto = double.parse(fil2Atto(value));
    var maxFee = double.parse(feeCap) * gasLimit;
    if ((balance < amountAtto + maxFee) && methodId == '0') {
      showCustomError('errorLowBalance'.tr);
      return;
    }
    if (methodId == '23') {
      var newOwner = ownerCtrl.text.trim();
      if (newOwner == '') {
        showCustomError('enterOwner'.tr);
        return;
      }
    }
    if (methodId == '3') {
      var newWorker = worker.text.trim();

      if (newWorker == '') {
        showCustomError('enterWorker'.tr);
        return;
      }
      if (controllers
          .map((ctrl) => ctrl.text.trim())
          .toList()
          .any((str) => str == '')) {
        showCustomError('enterController'.tr);
        return;
      }
    }
    if (singleStoreController.gas.value.feeCap == '0') {
      await getGas();
      if (singleStoreController.gas.value.feeCap == '0') {
        showCustomError("errorSetGas".tr);
        return;
      }
    }
    //var a = double.parse(_amountCtl.text.trim());
    if (nonce == null || nonce == -1) {
      showCustomError("errorGetNonce".tr);
      return;
    }
    if (singleStoreController.wal.readonly == 1) {
      var msg = await genMsg();
      singleStoreController.setPushBackPage(multiMainPage);
      Get.toNamed(mesBodyPage, arguments: {'mes': msg});
    } else {
      showPassDialog(context, (String pass) {
        pushMessage(pass);
      });
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

  String get to {
    return toCtrl.text.trim();
  }

  String get value {
    return valueCtrl.text.trim();
  }

  Future<TMessage> genMsg() async {
    var controller = singleStoreController;
    var p = await getParamsByMethod(to, fil2Atto(value));
    var decodeParams = jsonDecode(p);
    var msg = TMessage(
        version: 0,
        method: 2,
        nonce: realNonce,
        from: from,
        to: wallet.id,
        params: decodeParams['param'],
        value: '0',
        gasFeeCap: controller.gas.value.feeCap,
        gasLimit: controller.gas.value.gasLimit,
        gasPremium: controller.gas.value.premium);
    return msg;
  }

  void pushMessage(String pass) async {
    var controller = singleStoreController;
    var msg = await genMsg();
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(msg));
    var wal = singleStoreController.wal;
    var ck = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    //var ck = base64.encode(sk);
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
      print(res);
      controller.setGas(Gas());
      OpenedBox.multiMesInsance.put(
          res,
          StoreMultiMessage(
              pending: 1,
              from: from,
              to: wallet.id,
              value: '0',
              owner: from,
              msigTo: to,
              msigValue: fil2Atto(value),
              signedCid: res,
              type: 'proposal',
              blockTime:
                  (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      var oldNonce = nonceBoxInstance.get(from);
      nonceBoxInstance.put(
          from, Nonce(value: realNonce + 1, time: oldNonce.time));
    }
    Get.back();
  }

  void checkToShowMiners() async {
    var res = await getActiveMiners(wallet.id);
    if (res.isNotEmpty) {
      showCustomModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
          context: context,
          builder: (BuildContext context) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 800),
              child: Column(
                children: [
                  CommonTitle('selectMiner'.tr, showDelete: true),
                  Expanded(
                      child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    child: Column(
                      children: List.generate(res.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Get.back();
                            toCtrl.text = res[index];
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            margin: EdgeInsets.only(bottom: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: CustomColor.primary,
                                borderRadius: CustomRadius.b6),
                            child: CommonText.white(res[index]),
                          ),
                        );
                      }),
                    ),
                  ))
                ],
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var keyH = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      //resizeToAvoidBottomInset: methodId == '3',
      title: 'propose'.tr,
      footerText: 'sure'.tr,
      onPressed: () {
        handleConfirm();
      },
      actions: [
        Padding(
          child: GestureDetector(
              onTap: handleScan,
              child: Image(
                width: 20,
                image: AssetImage('images/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      body: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(12, 20, 12, methodId == '3' ? keyH + 120 : 120),
        child: Column(
          children: [
            Field(
                label: methodId != '0' ? 'minerAddr'.tr : 'to'.tr,
                controller: toCtrl,
                extra: GestureDetector(
                  child: Padding(
                    child:
                        Image(width: 20, image: AssetImage('images/book.png')),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onTap: () {
                    Get.toNamed(addressSelectPage).then((value) {
                      if (value != null) {
                        toCtrl.text = (value as Wallet).address;
                      }
                    });
                  },
                )),
            Visibility(
                visible: methodId == '0' || methodId == '16',
                child: Field(
                  label: 'amount'.tr,
                  controller: valueCtrl,
                  append: CommonText(
                      formatFil(singleStoreController.multiWal.balance)),
                )),
            AdvancedSet(
              method: methodId,
              hideMethods: true,
              onChange: (String m) {
                setState(() {
                  methodId = m;
                  if (m == '3' || m == '23') {
                    valueCtrl.text = '0';
                  }
                  if (m == '16') {
                    checkToShowMiners();
                  }
                });
              },
            ),
            Obx(() => SetGas(
                  maxFee: singleStoreController.maxFee,
                  gas: chainGas,
                )),
            SizedBox(
              height: 5,
            ),
            Visibility(
              visible: methodId == '23',
              child: Field(
                label: 'owner'.tr,
                controller: ownerCtrl,
              ),
            ),
            Visibility(
              child: ChangeWorkerAddress(
                worker: worker,
                controllers: controllers,
                add: addController,
                remove: removeController,
              ),
              visible: methodId == '3',
            )
          ],
        ),
      ),
    );
  }
}
