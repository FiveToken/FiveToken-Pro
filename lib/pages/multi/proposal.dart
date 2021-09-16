import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:oktoast/oktoast.dart';

/// Initiate proposal
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
  MultiSignWallet wallet = $store.multiWal;
  var nonceBoxInstance = OpenedBox.nonceInsance;
  String methodId = '0';
  int nonce;
  bool toIsMiner = false;
  TextEditingController worker = TextEditingController();
  List<TextEditingController> controllers = [TextEditingController()];
  String ownerId;
  BigInt signerBalance;
  BigInt minerBalance = BigInt.zero;
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
    FilecoinProvider.getNonceAndGas(to: wallet.id, method: 2);
    signerBalance = BigInt.tryParse($store.wal.balance);
    methodId = Get.arguments['method'] as String;
    if (methodId == '3' || methodId == '21' || methodId == '23') {
      valueCtrl.text = '0';
    }
  }

  /// serialize params
  Future<String> getParamsByMethod(String to, String value) async {
    String params = '';
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
      case '21':
        params = await Flotus.genConfirmUpdateWorkerKey(to);
        break;
      case '23':
        params =
            await Flotus.genProposalForChangeOwnerV3(this.ownerId, to, value);
        break;
      default:
    }
    return params;
  }

  void handleConfirm() async {
    var to = toCtrl.text.trim();
    var value = valueCtrl.text.trim();
    if (to == '') {
      showCustomError('enterTo'.tr);
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
    if (!$store.canPush) {
      showCustomLoading('Loading');
      var valid =
          await FilecoinProvider.getNonceAndGas(to: wallet.id, method: 2);
      dismissAllToast();
      if (!valid) {
        showCustomError('errorSetGas'.tr);
        return;
      }
    }
    var balance = BigInt.tryParse(wallet.balance);
    var amountAtto = BigInt.tryParse(fil2Atto(value));
    var maxFee = $store.gas.value.feeNum;
    if (signerBalance < maxFee) {
      showCustomError('from'.tr + 'errorLowBalance'.tr);
      return;
    }
    if (methodId == '0' && balance != null) {
      if ((balance < amountAtto)) {
        showCustomError('errorLowBalance'.tr);
        return;
      }
    }
    if (methodId == '16') {
      showCustomLoading('Loading');
      await getMinerBalance(to);
      dismissAllToast();
      if (minerBalance < amountAtto) {
        showCustomError('errorLowBalance'.tr);
        return;
      }
    }
    if (methodId == '23') {
      var newOwner = ownerCtrl.text.trim();
      if (newOwner == '') {
        showCustomError('enterOwner'.tr);
        return;
      }
      if (newOwner[1] != '0') {
        showCustomLoading('Loading');
        var ownerId = await getAddressActor(newOwner);
        dismissAllToast();
        if (ownerId == '') {
          showCustomError('searchOwnerFail'.tr);
          return;
        } else {
          this.ownerId = ownerId;
        }
      } else {
        this.ownerId = newOwner;
      }
    }
    if (methodId == '3') {
      var newWorker = worker.text.trim();

      if (newWorker == '') {
        showCustomError('enterWorker'.tr);
        return;
      }
      if (newWorker[1] != '0') {
        showCustomLoading('Loading');
        var actor = await getAddressActor(newWorker);
        dismissAllToast();
        if (actor == '') {
          showCustomError('notActiveWorker'.tr);
          return;
        }
      }
      if (controllers
          .map((ctrl) => ctrl.text.trim())
          .toList()
          .any((str) => str == '')) {
        showCustomError('enterController'.tr);
        return;
      }
    }
    if ($store.wal.readonly == 1) {
      var msg = await genMsg();
      $store.setPushBackPage(multiMainPage);
      Get.toNamed(mesBodyPage, arguments: {'mes': msg});
    } else {
      FilecoinProvider.checkSpeedUpOrMakeNew(
          context: context,
          onNew: () {
            showPassDialog(context, (String pass) {
              pushMessage(pass);
            });
          },
          onSpeedup: () {
            showPassDialog(context, (String pass) async {
              var wal = $store.wal;
              var private =
                  await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
              var res = await FilecoinProvider.speedup(
                  private: private, gas: $store.chainGas);
              if (res != '') {
                Get.back();
              }
            });
          });
    }
  }

  Future getMinerBalance(String addr) async {
    var meta = await getMinerInfo(addr);
    if (meta.balance != '0') {
      var balance = BigInt.tryParse(fil2Atto(meta.available));
      minerBalance = balance ?? BigInt.zero;
    }
  }

  String get from {
    return $store.wal.addrWithNet;
  }

  String get to {
    return toCtrl.text.trim();
  }

  String get value {
    return valueCtrl.text.trim();
  }

  Future<TMessage> genMsg() async {
    var controller = $store;
    var p = await getParamsByMethod(to, fil2Atto(value));
    var decodeParams = jsonDecode(p);
    var msg = TMessage(
        version: 0,
        method: 2,
        nonce: $store.nonce,
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
    var msg = await genMsg();
    var wal = $store.wal;
    var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    var res = await FilecoinProvider.sendMessage(
        message: msg,
        private: private,
        multiId: wallet.id,
        multiTo: to,
        multiValue: fil2Atto(value));
    if (res != '') {
      Get.back();
    }
  }

  void speedup(String pass) async {
    var wal = $store.wal;
    var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    var res =
        await FilecoinProvider.speedup(private: private, gas: $store.gas.value);
    if (res != '') {
      Get.back();
    }
  }

  /// if the select method is 16, auto display the worker of the owner
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
            AdvancedSet(
              method: methodId,
              label: 'proposalType'.tr,
              hideMethods: true,
              onChange: (String m) {
                setState(() {
                  methodId = m;
                  if (m == '3' || m == '21' || m == '23') {
                    valueCtrl.text = '0';
                  }
                  if (m == '16') {
                    checkToShowMiners();
                  }
                });
              },
            ),
            SizedBox(
              height: 12,
            ),
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
                  append: methodId == '0'
                      ? CommonText(formatFil($store.multiWal.balance))
                      : Container(),
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
            ),
            Obx(() => SetGas(
                  maxFee: $store.maxFee,
                  gas: $store.chainGas,
                )),
          ],
        ),
      ),
    );
  }
}
