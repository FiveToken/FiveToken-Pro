import 'package:fil/index.dart';

enum MessageType { MinerWithdraw, OwnerTransfer, MinerRecharge }
/// make unsigned message by given params
class MesMakePage extends StatefulWidget {
  @override
  State createState() => MesMakePageState();
}

class MesMakePageState extends State<MesMakePage> {
  StoreController controller = Get.find();
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  TextEditingController valueCtrl = TextEditingController();
  bool valueEnabled = true;
  final TextEditingController ownerCtrl = TextEditingController();
  String method = '0';
  var box = Hive.box<StoreUnsignedMessage>(unsignedMessageBox);
  bool showFrom = true;
  Wallet wallet = singleStoreController.wal;
  TextEditingController worker = TextEditingController();
  List<TextEditingController> controllers = [TextEditingController()];
  String sealType = '8';
  bool preventNext = false;
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

  void makeNewOrSpeed() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: Get.context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTitle(
                  'select'.tr,
                  showDelete: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  child: CommonText('hasPendingNew'.tr),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabCard(
                        items: [
                          CardItem(
                            label: 'speedup'.tr,
                            onTap: () {
                              Get.back();
                              speedUp();
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TabCard(
                        items: [
                          CardItem(
                            label: 'makeNew'.tr,
                            onTap: () {
                              Get.back();
                              makeNew();
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void handleSubmit(BuildContext context) async {
    var res = await makeMessage();
    if (res is TMessage) {
      if (res.value != null) {
        unFocusOf(context);
        singleStoreController.setPushBackPage(mainPage);
        Get.toNamed(mesBodyPage, arguments: {
          'mes': res,
        });
      } else {
        showCustomError('makeFail'.tr);
      }
    }
  }

  Future<dynamic> makeMessage() async {
    var from = fromCtrl.text.trim();
    var to = toCtrl.text.trim();
    var value = valueCtrl.text.trim();
    var params = '';
    if (value == '') {
      value = '0';
    }
    if (from == '') {
      showCustomError('enterFrom'.tr);
      return;
    }
    if (to == '' && method != '2') {
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
    if (method == '16') {
      params = '{"AmountRequested": "${fil2Atto(value)}"}';
      value = '0';
    }

    if (method == '23') {
      var newOwner = ownerCtrl.text.trim();
      if (newOwner == '') {
        showCustomError('enterOwner'.tr);
        return;
      }
      params = '\"$newOwner\"';
    }
    if (method == '2') {
      var w = worker.text.trim();
      if (w == '') {
        showCustomError('enterWorker'.tr);
        return;
      }
      if (w[1] == '1') {
        showCustomError('workerBls'.tr);
        return;
      }
      to = Global.netPrefix + '04';
      params = jsonEncode({
        "Peer": null,
        "Owner": from,
        "Worker": w,
        "Multiaddrs": null,
        "WindowPoStProofType": int.parse(sealType)
      });
    }
    if (method == '3') {
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
      params = jsonEncode({
        'NewWorker': worker.text.trim(),
        'NewControlAddrs': controllers.map((ctrl) => ctrl.text.trim()).toList()
      });
    }
    var res = await buildMessage({
      'from': from,
      'to': to,
      'value': fil2Atto(value),
      'method': int.parse(method)
    }, params == '' ? null : params);
    return res;
  }

  List<StoreSignedMessage> getPushList() {
    return OpenedBox.pushInsance.values
        .where((mes) =>
            mes.pending == 1 && mes.message.message.from == wallet.addrWithNet)
        .toList();
  }

  void speedUp() {
    var list = getPushList();
    var usedMes = list[0].message.message;
    if (list.length != 1) {
      var minNonceMes = list[0];
      list.forEach((mes) {
        if (mes.nonce < minNonceMes.nonce) {
          minNonceMes = mes;
        }
      });
      usedMes = minNonceMes.message.message;
    }
    var caculatePremium = (int.parse(usedMes.gasPremium) * 1.3).truncate();
    var caculateFeeCap = (int.parse(usedMes.gasFeeCap) * 1.3).truncate();
    usedMes.gasPremium = caculatePremium.toString();
    usedMes.gasFeeCap = caculateFeeCap.toString();
    singleStoreController.setPushBackPage(mainPage);
    Get.toNamed(mesBodyPage, arguments: {
      'mes': usedMes,
    });
  }

  void makeNew() async {
    var list = getPushList();
    var nonce = list[0].message.message.nonce;
    if (list.length != 1) {
      list.forEach((mes) {
        if (mes.nonce > nonce) {
          nonce = mes.nonce;
        }
      });
    }
    var res = await makeMessage();
    if (res is TMessage) {
      if (res.value != null) {
        res.nonce = nonce + 1;
        unFocusOf(context);
        singleStoreController.setPushBackPage(mainPage);
        Get.toNamed(mesBodyPage, arguments: {
          'mes': res,
        });
      } else {
        showCustomError('makeFail'.tr);
      }
    }
  }

  void checkPendingList() async {
    var pushList = getPushList();
    if (pushList.isNotEmpty) {
      var res = await getBalance(wallet);
      if (res.nonce != -1) {
        pushList.forEach((mes) {
          if (mes.nonce < res.nonce) {
            OpenedBox.pushInsance.delete(mes.cid);
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkPendingList();

    var args = Get.arguments;
    if (args != null) {
      var mesType = args['type'];
      switch (mesType) {
        case MessageType.OwnerTransfer:
          fromCtrl.text = Get.arguments['from'];
          break;
        case MessageType.MinerWithdraw:
          //fromCtrl.text = Get.arguments['from'];
          var list = OpenedBox.monitorInsance.values
              .where((addr) =>
                  addr.type == 'owner' &&
                  addr.miner == singleStoreController.wal.addrWithNet)
              .toList();
          if (list.isNotEmpty) {
            var owner = list[0].cid;
            if (owner.trim()[1] == '2') {
              preventNext = true;
              nextTick(() {
                showCustomError('ownerIsMulti'.tr);
              });
            }
            fromCtrl.text = list[0].cid;
          }
          toCtrl.text = Get.arguments['to'];
          valueCtrl.text = '0';
          method = '16';
          break;
        default:
      }
      var origin = args['origin'];
      if (origin != null) {
        this.showFrom = false;
        fromCtrl.text = wallet.addrWithNet;
      }
    }
  }

  void changeMethod(String method) {
    this.method = method;
  }

  @override
  Widget build(BuildContext context) {
    var keyH = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      title: 'first'.tr,
      footerText: 'next'.tr,
      actions: [
        ScanAction(handleScan: () {
          Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
              .then((scanResult) {
            if (scanResult != '') {
              if (!isValidAddress(scanResult)) {
                showCustomError('wrongAddr'.tr);
              }
              toCtrl.text = scanResult;
            }
          });
        })
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
                visible: showFrom,
                child: Field(
                  label: 'from'.tr,
                  controller: fromCtrl,
                  extra: GestureDetector(
                    child: Padding(
                      child: Image(
                          width: 20, image: AssetImage('images/book.png')),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onTap: () {
                      Get.toNamed(addressSelectPage).then((value) {
                        if (value != null) {
                          fromCtrl.text = (value as Wallet).address;
                        }
                      });
                    },
                  ),
                )),
            Visibility(
                visible: method != '2',
                child: Field(
                  label: method == '0' ? 'to'.tr : 'minerAddr'.tr,
                  controller: toCtrl,
                  extra: GestureDetector(
                    child: Padding(
                      child: Image(
                          width: 20, image: AssetImage('images/book.png')),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onTap: () {
                      Get.toNamed(addressSelectPage).then((value) {
                        if (value != null) {
                          toCtrl.text = (value as Wallet).address;
                        }
                      });
                    },
                  ),
                )),
            Visibility(
              child: Field(
                  label: 'amount'.tr,
                  controller: valueCtrl,
                  type: TextInputType.numberWithOptions(decimal: true),
                  // append: CommonText(
                  //     formatFil(singleStoreController.wal.balance)),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                  ]),
              visible: method == '0' || method == '16',
            ),
            AdvancedSet(
              method: method,
              onChange: (String v) {
                setState(() {
                  this.method = v;
                  if (method == '3' || method == '23') {
                    valueCtrl.text = '0';
                  }
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Visibility(
                  visible: method == '23',
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
                  visible: method == '3',
                ),
                Visibility(
                    visible: method == '2',
                    child: CreateMiner(
                        workerController: worker,
                        onChange: (v) {
                          setState(() {
                            this.sealType = v;
                          });
                        },
                        sealType: sealType))
              ],
            ),
          ],
        ),
        padding:
            EdgeInsets.fromLTRB(12, 20, 12, method == '3' ? keyH + 120 : 120),
      ),
      onPressed: () {
        if (preventNext) {
          showCustomError('ownerIsMulti'.tr);
          return;
        }
        var list = getPushList();
        if (list.isNotEmpty) {
          makeNewOrSpeed();
        } else {
          handleSubmit(context);
        }
        //handleSubmit(context);
      },
    );
  }
}

class AdvancedSet extends StatelessWidget {
  final String method;
  final Function(String) onChange;
  final bool hideMethods;
  AdvancedSet({this.method, this.onChange, this.hideMethods = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: CommonText.main('op'.tr),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText(
                  MethodMap().getMethodDes(method),
                  size: 14,
                  color: Colors.white,
                ),
                Spacer(),
                CommonText(
                  'advanced'.tr,
                  color: Colors.white,
                  size: 14,
                ),
                Image(width: 18, image: AssetImage('images/right-w.png'))
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Get.toNamed(mesMethodPage, arguments: {
          'method': method,
          'hideMethods': hideMethods,
        }).then((value) {
          if (value != null) {
            try {
              int.parse(value);
              onChange(value);
            } catch (e) {}
          }
        });
      },
    );
  }
}

class ChangeWorkerAddress extends StatelessWidget {
  final TextEditingController worker;
  final List<TextEditingController> controllers;
  final Noop add;
  final SingleParamCallback<int> remove;
  ChangeWorkerAddress(
      {@required this.worker,
      @required this.controllers,
      @required this.add,
      @required this.remove});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Field(
          label: 'worker'.tr,
          controller: worker,
          extra: GestureDetector(
              onTap: () {
                Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
                    .then((scanResult) {
                  if (scanResult != '' && isValidAddress(scanResult)) {
                    worker.text = scanResult;
                  }
                });
              },
              child: Container(
                child: Image(
                  width: 16,
                  image: AssetImage('images/scan.png'),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
              )),
        ),
        Container(
          child: CommonText.main('controller'.tr),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        Column(
          children: List.generate(controllers.length, (index) {
            var ctrl = controllers[index];
            return Field(
              controller: ctrl,
              extra: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Get.toNamed(scanPage,
                                arguments: {'scene': ScanScene.Address})
                            .then((scanResult) {
                          if (scanResult != '' && isValidAddress(scanResult)) {
                            ctrl.text = scanResult;
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
                      remove(index);
                    },
                  ),
                  SizedBox(
                    width: 12,
                  )
                ],
              ),
            );
          }),
        ),
        SizedBox(
          height: 5,
        ),
        FButton(
          text: 'addController'.tr,
          width: double.infinity,
          height: 50,
          corner: FCorner.all(6),
          color: Colors.white,
          onPressed: () {
            add();
          },
          image: IconPlus,
        )
      ],
    );
  }
}

class CreateMiner extends StatelessWidget {
  final TextEditingController workerController;
  final String sealType;
  final SingleParamCallback<String> onChange;
  CreateMiner({this.workerController, this.sealType, this.onChange});
  @override
  Widget build(BuildContext context) {
    return Layout.colStart([
      Field(
        label: 'Worker(f3)',
        controller: workerController,
        extra: GestureDetector(
            onTap: () {
              Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
                  .then((scanResult) {
                if (scanResult != '' && isValidAddress(scanResult)) {
                  workerController.text = scanResult;
                }
              });
            },
            child: Container(
              child: Image(
                width: 16,
                image: AssetImage('images/scan.png'),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
            )),
      ),
      Row(
        children: [
          CommonText.main('sectorType'.tr),
          Spacer(),
          Radio(
              activeColor: CustomColor.primary,
              value: "8",
              groupValue: sealType,
              onChanged: onChange),
          CommonText.main('32G'),
          Radio(
            activeColor: CustomColor.primary,
            value: "9",
            groupValue: sealType,
            onChanged: onChange,
          ),
          CommonText.main('64G'),
        ],
      )
    ]);
  }
}
