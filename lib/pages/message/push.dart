import 'package:fil/index.dart';

/// push signed message to lotus node
class MesPushPage extends StatefulWidget {
  @override
  State createState() => MesPushPageState();
}

class MesPushPageState extends State<MesPushPage> {
  TextEditingController controller = TextEditingController();
  SignedMessage message;
  bool showDisplay = false;
  Gas gas;

  /// store message which method is transfer, propose, approve, withdrawbalance or exec
  void checkToStoreMessage(TMessage mes, String cid) {
    var from = mes.from;
    var to = mes.to;
    var now = getSecondSinceEpoch();
    if (OpenedBox.addressInsance.containsKey(from)) {
      var m = StoreMessage(
          pending: 1,
          from: from,
          to: to,
          nonce: mes.nonce,
          value: mes.value,
          owner: mes.from,
          signedCid: cid,
          blockTime: now);
      if ([0, 2, 3, 16, 21, 23].contains(mes.method)) {
        if ([0, 16, 21, 23].contains(mes.method)) {
          var methodName = <String, String>{
            '0': FilecoinMethod.transfer,
            '16': FilecoinMethod.withdraw,
            '21': FilecoinMethod.confirmUpdateWorkerKey,
            '23': FilecoinMethod.changeOwner
          };
          m.methodName = methodName[mes.method.toString()];
          OpenedBox.messageInsance.put(cid, m);
        }
        if (mes.method == 2) {
          if (mes.to == FilecoinAccount.f04) {
            m.methodName = FilecoinMethod.createMiner;
          }
          if (mes.to == FilecoinAccount.f01) {
            m.methodName = FilecoinMethod.exec;
          }
          if (!OpenedBox.multiInsance.containsKey(mes.to)) {
            OpenedBox.messageInsance.put(cid, m);
          }
        }
        if (mes.method == 3 && !OpenedBox.multiInsance.containsKey(mes.to)) {
          m.methodName = FilecoinMethod.changeWorker;
          OpenedBox.messageInsance.put(cid, m);
        }
      }
    }
  }

  void handlePush(BuildContext context, {bool checkGas = true}) async {
    if (message == null) {
      return;
    }
    // if (checkGas && gas != null && gas.feeCap != '0') {
    //   try {
    //     /// compare gas fee
    //     /// if fee used in message was too small, display a dialog
    //     var mes = message.message;
    //     var nowMaxFee = double.parse(gas.feeCap) * gas.gasLimit;
    //     var maxFee = double.parse(mes.gasFeeCap) * mes.gasLimit;
    //     if (nowMaxFee > 1.2 * maxFee) {
    //       showGasDialog();
    //       return;
    //     }
    //   } catch (e) {}
    // }
    try {
      await Global.provider.sendSignedMessage(message.toLotusSignedMessage(),
          callback: (res) {
        var now = DateTime.now().millisecondsSinceEpoch;
        var mes = message.message;
        checkToStoreMessage(mes, res);
        OpenedBox.pushInsance.put(
            res,
            StoreSignedMessage(
                time: now.toString(),
                message: message,
                cid: res,
                pending: 1,
                nonce: message.message.nonce));
        showCustomToast('pushSuccess'.tr);
        var page = $store.pushBackPage;
        var backPage = mainPage;
        if (page != '') {
          backPage = page;
        }
        Navigator.of(context)
            .popUntil((route) => route.settings.name == backPage);
      });
    } catch (e) {
      print(e);
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.SignedMessage})
        .then((scanResult) {
      if (scanResult != '') {
        try {
          var result = jsonDecode(scanResult);
          SignedMessage message = SignedMessage.fromJson(result);
          if (message.message.valid) {
            // getGas(message.message);
            setState(() {
              this.message = message;
              this.showDisplay = true;
            });
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  Future getGas(TMessage mes) async {
    try {
      var gas = await Global.provider.getGasDetail(
          to: mes.to, methodName: FilecoinMethod.getMethodNameByMessage(mes));
      this.gas = gas;
    } catch (e) {
      print(e);
    }
  }

  void showDetail(SignedMessage message) {
    setState(() {
      this.message = message;
      this.showDisplay = true;
    });
  }

  void showGasDialog() {
    showCustomDialog(
        context,
        Column(
          children: [
            CommonTitle(
              'feeWave'.tr,
              showDelete: true,
            ),
            Container(
                child: CommonText.center('feeDes'.tr),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                )),
            Divider(
              height: 1,
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'reMake'.tr,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                      Get.back();
                    },
                  )),
                  Container(
                    width: .2,
                    color: CustomColor.grey,
                  ),
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'continueSend'.tr,
                        color: CustomColor.primary,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                      handlePush(context, checkGas: false);
                    },
                  )),
                ],
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'third'.tr,
      footerText: 'push'.tr,
      onPressed: () {
        if (!showDisplay) {
          return;
        }
        handlePush(context);
      },
      actions: [ScanAction(handleScan: handleScan)],
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Layout.colStart([
            CommonText(
              'mesPush'.tr,
              size: 16,
              weight: FontWeight.w500,
            ),
            Container(
              child: CommonText('scanSign'.tr),
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
            ),
            showDisplay
                ? DisplayMessage(
                    footerText: 'viewDetail'.tr,
                    onTap: () {
                      showCustomModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: CustomRadius.top),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 500,
                              child: Column(
                                children: [
                                  CommonTitle(
                                    'detail'.tr,
                                    showDelete: true,
                                  ),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: GestureDetector(
                                      onTap: () {
                                        copyText(jsonEncode(
                                            message.toLotusSignedMessage()));
                                        showCustomToast('copySucc'.tr);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(20),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[200]),
                                            borderRadius: CustomRadius.b6),
                                        child: CommonText(
                                            JsonEncoder.withIndent(' ').convert(
                                                message
                                                    .toLotusSignedMessage())),
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                            );
                          });
                    },
                    message: message.message,
                  )
                : Column(
                    children: [
                      GestureDetector(
                        child: CommonCard(Container(
                          height: Get.height / 2,
                          alignment: Alignment.center,
                          child: CommonText(
                            'clickCode'.tr,
                            size: 16,
                          ),
                        )),
                        onTap: handleScan,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var data =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          var result = data.text;
                          var valid = result.indexOf('Message') > 0 &&
                              result.indexOf('Signature') > 0;
                          if (!valid) {
                            showCustomError('copyErrorMes'.tr);
                            return;
                          }
                          try {
                            var res = jsonDecode(result);
                            SignedMessage message = SignedMessage.fromJson(res);
                            if (message.message.valid) {
                              // getGas(message.message);
                              setState(() {
                                this.message = message;
                                this.showDisplay = true;
                              });
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'copyMes'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CustomColor.grey,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
            SizedBox(
              height: 12,
            ),
            Visibility(
              child: DocButton(
                page: mesPushPage,
              ),
              visible: !showDisplay,
            )
          ]),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20)),
    );
  }
}
