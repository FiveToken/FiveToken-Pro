import 'package:decimal/decimal.dart';
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
  String innerParams;
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
    Global.provider
        .getNonceAndGas(to: wallet.id, method: 2, methodName: 'Propose');
    signerBalance = BigInt.tryParse($store.wal.balance);
    if (Get.arguments['params'] is Map) {
      var params = Get.arguments['params'] as Map;
      var innerParams = Get.arguments['innerParams'];
      var method = params['Method'].toString();
      methodId = method;

      if (methodId == '0') {
        var v = Decimal.parse(params['Value']);
        var n = v / Decimal.fromInt(pow(10, 18));
        valueCtrl.text = n.toString();
        toCtrl.text = params['To'];
      } else {
        toCtrl.text = params['To'];
        if (methodId == '3') {
          var newWorker = innerParams['NewWorker'];
          var newCtrls = innerParams['NewControlAddrs'];
          if (newWorker is String && newCtrls is List) {
            worker.text = newWorker;
            controllers = List.generate(newCtrls.length,
                (index) => TextEditingController(text: newCtrls[index]));
          }
        } else if (methodId == '16') {
          var v = Decimal.parse(innerParams['AmountRequested']);
          var n = v / Decimal.fromInt(pow(10, 18));
          valueCtrl.text = n.toString();
        } else if (methodId == '23') {
          ownerCtrl.text = innerParams;
        }
      }
    } else {
      methodId = Get.arguments['method'] as String;
      if (methodId == '3' || methodId == '21' || methodId == '23') {
        valueCtrl.text = '0';
      }
      if (methodId == '16') {
        checkToShowMiners();
      }
    }
  }

  String get methodName => <String, String>{
        '0': FilecoinMethod.send,
        '3': FilecoinMethod.changeWorker,
        '16': FilecoinMethod.withdraw,
        '21': FilecoinMethod.confirmUpdateWorkerKey,
        '23': FilecoinMethod.changeOwner,
      }[methodId];

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
        this.innerParams = jsonEncode({
          'NewWorker': worker.text,
          'NewControlAddrs':
              controllers.map((ctrl) => ctrl.text.trim()).toList()
        });
        break;
      case '16':
        params = await Flotus.genProposalForWithdrawBalanceV3(to, value);
        innerParams = jsonEncode({"AmountRequested": value});
        break;
      case '21':
        params = await Flotus.genConfirmUpdateWorkerKey(to);
        break;
      case '21':
        params = await Flotus.genConfirmUpdateWorkerKey(to);
        break;
      case '23':
        params =
            await Flotus.genProposalForChangeOwnerV3(this.ownerId, to, value);
        this.innerParams = this.ownerId;
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
      var valid = await Global.provider
          .getNonceAndGas(to: wallet.id, method: 2, methodName: 'Propose');
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
        try {
          var ownerId = await Global.provider.getActorId(newOwner);
          dismissAllToast();
          this.ownerId = ownerId;
        } catch (e) {
          showCustomError('searchOwnerFail'.tr);
          return;
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
        try {
          await Global.provider.getActorId(newWorker);
          dismissAllToast();
        } catch (e) {
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
      Global.provider.checkSpeedUpOrMakeNew(
          context: context,
          nonce: $store.nonce,
          onNew: (increaseNonce) {
            showPassDialog(context, (String pass) {
              pushMessage(pass, increaseNonce: increaseNonce);
            });
          },
          onSpeedup: () {
            showPassDialog(context, (String pass) async {
              var wal = $store.wal;
              var private =
                  await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
              try {
                await Global.provider.speedup(
                    private: private,
                    gas: $store.chainGas,
                    multiId: wallet.id,
                    methodName: FilecoinMethod.propose);
                Get.back();
              } catch (e) {
                print(e);
              }
            });
          });
    }
  }

  Future getMinerBalance(String addr) async {
    try {
      var res = await Global.provider.getBalance(addr);
      minerBalance = BigInt.tryParse(res) ?? BigInt.zero;
    } catch (e) {
      print(e);
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

  void pushMessage(String pass, {bool increaseNonce}) async {
    var msg = await genMsg();
    var wal = $store.wal;
    var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    try {
      var multiMessage = CacheMultiMessage(
          from: msg.from,
          to: msg.to,
          pending: 1,
          owner: msg.from,
          nonce: msg.nonce,
          method: methodName,
          innerParams: innerParams,
          params: jsonEncode(
              {"To": to, "Value": fil2Atto(value), "Method": 3, "Params": ''}),
          fee: msg.maxFee.toString());
      await Global.provider.sendMessage(
          message: msg,
          private: private,
          multiId: wallet.id,
          multiTo: to,
          increaseNonce: increaseNonce,
          multiMessage: multiMessage,
          callback: (res) {
            multiMessage.cid = res;
            multiMessage.blockTime = getSecondSinceEpoch();
            OpenedBox.multiProposeInstance.put(res, multiMessage);
            Navigator.popUntil(
                context, (route) => route.settings.name == multiMainPage);
          });
    } catch (e) {
      print(e);
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  /// if the select method is 16, auto display the worker of the owner
  void checkToShowMiners() async {
    try {
      var res = await Global.provider.getActiveMiners(wallet.id);
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
    } catch (e) {
      print(e);
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
            SizedBox(height: 20),
            DocButton(
              page: multiProposalPage,
            )
          ],
        ),
      ),
    );
  }
}
