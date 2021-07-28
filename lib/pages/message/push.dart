import 'package:fil/index.dart';

class MesPushPage extends StatefulWidget {
  @override
  State createState() => MesPushPageState();
}

class MesPushPageState extends State<MesPushPage> {
  TextEditingController controller = TextEditingController();
  SignedMessage message;
  bool showDisplay = false;
  Gas gas;
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
      if ([0, 2, 3, 16].contains(mes.method)) {
        var multiMes = StoreMultiMessage(
          pending: 1,
          from: from,
          to: to,
          value: '0',
          owner: from,
          blockTime: now,
          msigTo: '',
          msigValue: '0',
          signedCid: cid,
          type: 'proposal',
        );
        if ([0, 16].contains(from)) {
          OpenedBox.messageInsance.put(cid, m);
        }
        if (mes.method == 2) {
          if (OpenedBox.multiInsance.containsKey(mes.to)) {
            OpenedBox.multiMesInsance.put(cid, multiMes);
          } else {
            OpenedBox.messageInsance.put(cid, m);
          }
        }
        if (mes.method == 3) {
          multiMes.type = 'approval';
          if (OpenedBox.multiInsance.containsKey(mes.to)) {
            OpenedBox.multiMesInsance.put(cid, multiMes);
          }
        }
      }
    }
  }

  void handlePush(BuildContext context, {bool checkGas = true}) async {
    if (message == null) {
      return;
    }
    if (checkGas && gas != null && gas.feeCap != '0') {
      try {
        var mes = message.message;
        var nowMaxFee = double.parse(gas.feeCap) * gas.gasLimit;
        var maxFee = double.parse(mes.gasFeeCap) * mes.gasLimit;
        if (nowMaxFee > 1.2 * maxFee) {
          showGasDialog();
          return;
        }
      } catch (e) {}
    }
    try {
      var res = await pushSignedMsg(message.toLotusSignedMessage());
      if (res != '') {
        var now = DateTime.now().millisecondsSinceEpoch;
        var mes = message.message;
        checkToStoreMessage(mes, res);
        Hive.box<StoreSignedMessage>(pushMessageBox).put(
            res,
            StoreSignedMessage(
                time: now.toString(),
                message: message,
                cid: res,
                pending: 1,
                nonce: message.message.nonce));
        showCustomToast('pushSuccess'.tr);
        var page = singleStoreController.pushBackPage;
        var backPage = mainPage;
        if (page != '') {
          backPage = page;
        }
        Navigator.of(context)
            .popUntil((route) => route.settings.name == backPage);
      }
    } catch (e) {
      print(e);
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
            getGas(message.message);
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
    var res = await getGasDetail(to: mes.to, method: mes.method);
    if (res.feeCap != '0') {
      this.gas = res;
    }
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
      footerText: 'send'.tr,
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
                                    child: Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[200]),
                                          borderRadius: CustomRadius.b6),
                                      child: CommonText(
                                          JsonEncoder.withIndent(' ').convert(
                                              message.toLotusSignedMessage())),
                                    ),
                                  ))
                                ],
                              ),
                            );
                          });
                    },
                    message: message.message,
                  )
                : GestureDetector(
                    child: CommonCard(Container(
                      height: Get.height / 2,
                      alignment: Alignment.center,
                      child: CommonText(
                        'clickCode'.tr,
                        size: 16,
                      ),
                    )),
                    onTap: handleScan,
                  )
          ]),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20)),
    );
  }
}
