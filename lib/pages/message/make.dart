import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

enum MessageType { MinerManage, OwnerTransfer, MinerRecharge }

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
  Wallet wallet = $store.wal;
  TextEditingController worker = TextEditingController();
  List<TextEditingController> controllers = [TextEditingController()];
  String sealType = '8';
  bool preventNext = false;
  Timer timer;
  BigInt fromBalance = BigInt.zero;
  BigInt minerBalance = BigInt.zero;
  bool showTips = false;
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
      unFocusOf(context);
      $store.setPushBackPage(mainPage);
      Get.toNamed(mesBodyPage, arguments: {
        'mes': res,
      });
    }
  }

  Future<dynamic> makeMessage() async {
    var from = fromCtrl.text.trim();
    var to = toCtrl.text.trim();
    var value = valueCtrl.text.trim();
    var params = '';
    var prefix = 'from'.tr;

    if (!['0', '16'].contains(method)) {
      value = '0';
    }
    if (from == '') {
      showCustomError('enterFrom'.tr);
      return;
    }
    if (to == '' && method != '2') {
      showCustomError('enterTo'.tr);
      return;
    }
    if (!isValidAddress(to) && method != '2') {
      showCustomError('errorAddr'.tr);
      return;
    }
    if (value == '' && ['0', '16'].contains(method)) {
      showCustomError('enterValidAmount'.tr);
      return;
    }
    try {
      double.parse(value);
    } catch (e) {
      showCustomError('enterValidAmount'.tr);
      return;
    }
    var requestValue = fil2Atto(value);
    if (method == '16') {
      params = '{"AmountRequested": "${fil2Atto(value)}"}';
      value = '0';
      prefix = 'Owner';
    }
    showCustomLoading('Loading');
    if (fromBalance == BigInt.zero) {
      await getFromBalance(from);
      if (fromBalance == BigInt.zero) {
        showCustomError(prefix + 'errorLowBalance'.tr);
        return;
      }
    }
    if (method == '16' && minerBalance == BigInt.zero) {
      await getMinerBalance(to);
    }
    if (method == '16' && minerBalance < BigInt.tryParse(requestValue)) {
      showCustomError('errorLowBalance'.tr);
      return;
    }
    var newOwner = ownerCtrl.text.trim();
    if (method == '23') {
      if (newOwner == '') {
        showCustomError('enterOwner'.tr);
        return;
      }
      if (newOwner[1] != '0') {
        var ownerId = await getAddressActor(newOwner);
        if (ownerId == '') {
          showCustomError('searchOwnerFail'.tr);
          return;
        } else {
          newOwner = ownerId;
        }
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
      var actor = await getAddressActor(w);
      if (actor == '') {
        showCustomError('invalidWorker'.tr);
        return;
      }
      to = FilecoinAccount.f04;
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
      if (newWorker[1] != '0') {
        var actor = await getAddressActor(newWorker);
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
      params = jsonEncode({
        'NewWorker': worker.text.trim(),
        'NewControlAddrs': controllers.map((ctrl) => ctrl.text.trim()).toList()
      });
    }
    try {
      var res = await buildMessage({
        'from': from,
        'to': to,
        'value': fil2Atto(value),
        'method': int.parse(method)
      }, params == '' ? null : params);
      var gas = Gas(
          feeCap: res.gasFeeCap,
          gasLimit: res.gasLimit,
          premium: res.gasPremium);
      var valueNum = BigInt.tryParse(fil2Atto(value)) ?? BigInt.zero;
      if (fromBalance < valueNum + gas.feeNum) {
        showCustomError(prefix + 'errorLowBalance'.tr);
        return;
      }
      dismissAllToast();
      return res;
    } catch (e) {
      print(e);
    }
  }

  List<StoreSignedMessage> getPushList() {
    var wal = $store.wal;
    return OpenedBox.pushInsance.values.where((mes) {
      var source = $store.wal.addrWithNet;
      if (wal.walletType == 2) {
        var list = OpenedBox.monitorInsance.values
            .where(
                (addr) => addr.miner == wal.addrWithNet && addr.type == 'owner')
            .toList();
        if (list.isNotEmpty) {
          source = list[0].cid;
        }
      }
      return mes.from == source;
    }).toList();
  }

  void speedUp() {
    var msg = FilecoinProvider.getIncreaseGasMessage();
    $store.setPushBackPage(mainPage);
    Get.toNamed(mesBodyPage, arguments: {
      'mes': msg,
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
      res.nonce = nonce + 1;
      unFocusOf(context);
      $store.setPushBackPage(mainPage);
      Get.toNamed(mesBodyPage, arguments: {
        'mes': res,
      });
    }
  }

  @override
  void initState() {
    super.initState();

    var args = Get.arguments;
    if (args != null) {
      var mesType = args['type'];
      switch (mesType) {
        case MessageType.OwnerTransfer:
          fromCtrl.text = Get.arguments['from'];
          break;
        case MessageType.MinerManage:
          //fromCtrl.text = Get.arguments['from'];
          var list = OpenedBox.monitorInsance.values
              .where((addr) =>
                  addr.type == 'owner' && addr.miner == $store.wal.addrWithNet)
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
          // valueCtrl.text = '0';
          method = Get.arguments['method'];
          showTips = true;
          if (method == '16') {
            getMinerBalance(Get.arguments['to']);
          }
          break;
        default:
      }
      var origin = args['origin'];
      if (origin != null) {
        this.showFrom = false;
        fromCtrl.text = wallet.addrWithNet;
      }
      if (fromCtrl.text != '') {
        getFromBalance(fromCtrl.text);
      }
    }
  }

  void changeMethod(String method) {
    this.method = method;
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future getFromBalance(String addr) async {
    var res = await getBalance(fromCtrl.text);
    if (res.balance != '0') {
      var balance = BigInt.tryParse(res.balance);
      fromBalance = balance ?? BigInt.zero;
    }
  }

  Future getMinerBalance(String addr) async {
    var meta = await getMinerInfo(addr);
    if (meta.balance != '0') {
      var balance = BigInt.tryParse(fil2Atto(meta.available));
      minerBalance = balance ?? BigInt.zero;
    }
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
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            padding:
                EdgeInsets.fromLTRB(12, 20, 12, method == '3' ? keyH + 20 : 20),
            child: Column(
              children: [
                Column(
                  children: [
                    AdvancedSet(
                      method: method,
                      label: 'messageType'.tr,
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
                      height: 12,
                    ),
                    Visibility(
                        visible: showFrom,
                        child: Field(
                          label: 'from'.tr,
                          controller: fromCtrl,
                          extra: GestureDetector(
                            child: Padding(
                              child: Image(
                                  width: 20,
                                  image: AssetImage('images/book.png')),
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
                                  width: 20,
                                  image: AssetImage('images/book.png')),
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
                          //     formatFil($store.wal.balance)),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                          ]),
                      visible: method == '0' || method == '16',
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
                    Visibility(
                      child: Tips(['minerManageTip'.tr]),
                      visible: showTips,
                    )
                  ],
                )
              ],
            ),
          )),
          SizedBox(
            height: 120,
          )
        ],
      ),
      onPressed: () async {
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
  final String label;
  AdvancedSet(
      {this.method,
      this.onChange,
      this.hideMethods = false,
      @required this.label});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   child: CommonText.main(label),
          //   padding: EdgeInsets.symmetric(vertical: 12),
          // ),
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
        label: 'workerf3'.tr,
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
