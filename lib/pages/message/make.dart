import 'dart:async';
import 'dart:convert';
import 'package:fbutton/fbutton.dart';
import 'package:fil/api/update.dart';
import 'package:fil/bloc/make/make_bloc.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/button.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/other.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

import 'deposit.dart';
import 'method.dart';

enum MessageType { MinerManage, OwnerTransfer, MinerRecharge }

/// make unsigned message by given params
class MesMakePage extends StatefulWidget {
  @override
  State createState() => MesMakePageState();
}

/// page of message make
class MesMakePageState extends State<MesMakePage> {
  StoreController controller = Get.find();
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  TextEditingController valueCtrl = TextEditingController();
  bool valueEnabled = true;
  final TextEditingController ownerCtrl = TextEditingController();
  bool showFrom = true;
  Wallet wallet = $store.wal;
  TextEditingController worker = TextEditingController();
  bool preventNext = false;
  BigInt fromBalance = BigInt.zero;
  BigInt minerBalance = BigInt.zero;
  bool showTips = false;
  int fromNonce = -1;
  StreamSubscription sub;
  String methods = '16';
  void addController(BuildContext context) {
    TextEditingController worker = TextEditingController();
    BlocProvider.of<MakeBloc>(context).add(AddEvent(worker));
  }

  void removeController(BuildContext context, int index) {
    BlocProvider.of<MakeBloc>(context).add(DeleteEvent(type: index));
  }

  void makeNewOrSpeed(state) {
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
                      TapCard(
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
                      TapCard(
                        items: [
                          CardItem(
                            label: 'makeNew'.tr,
                            onTap: () {
                              Get.back();
                              makeNew(context, state);
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

  void handleSubmit(BuildContext context, state) async {
    var res = await makeMessage(state);
    if (res is TMessage) {
      addOperation('make_mes');
      unFocusOf(context);
      goConfirm(res);
      // $store.setPushBackPage(mainPage);
      // Get.toNamed(mesBodyPage, arguments: {
      //   'mes': res,
      // });
    }
  }

  Future<dynamic> makeMessage(state) async {
    String method = state.method as String;
    String sealType = state.sealType as String;
    List<TextEditingController> controllers =
        state.controllers as List<TextEditingController>;
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
    if (!isValidAddress(from)) {
      showCustomError('errFromAddr'.tr);
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
      try {
        await getFromBalance(from);
      } catch (e) {
        showCustomError('getFromBalanceFail'.tr);
        return;
      }
      if (fromBalance == BigInt.zero) {
        showCustomError(prefix + 'errorLowBalance'.tr);
        return;
      }
    }
    if (method == '0' && fromBalance < BigInt.parse(requestValue)) {
      showCustomError(prefix + 'errorLowBalance'.tr);
      return;
    }

    if (method == '16' && minerBalance == BigInt.zero) {
      try {
        await getMinerBalance(to);
      } catch (e) {
        showCustomError('getMinerBalanceFail'.tr);
        return;
      }
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
        try {
          var ownerId = await Global.provider.getActorId(newOwner);
          newOwner = ownerId;
        } catch (e) {
          showCustomError('searchOwnerFail'.tr);
          return;
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

      try {
        await Global.provider.getActorId(w);
      } catch (e) {
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
        try {
          await Global.provider.getActorId(newWorker);
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
      params = jsonEncode({
        'NewWorker': worker.text.trim(),
        'NewControlAddrs': controllers.map((ctrl) => ctrl.text.trim()).toList()
      });
    }
    try {
      var res = await Global.provider.buildMessage({
        'from': from,
        'to': to,
        'value': fil2Atto(value),
        'method': int.parse(method),
        'params': params == '' ? null : params
      });
      if (method == '16') {
        res.args = params;
      }
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
      showCustomError('makeFail'.tr);
      print(e);
    }
  }

  List<StoreSignedMessage> getPushList() {
    var wal = $store.wal;

    return OpenedBox.pushInsance.values.where((mes) {
      var source = $store.wal.addressWithNet;
      if (wal.walletType == 2) {
        var list = OpenedBox.minerAddressInstance.values
            .where((addr) =>
                addr.miner == wal.addressWithNet && addr.type == 'owner')
            .toList();
        if (list.isNotEmpty) {
          source = list[0].address;
        }
      }
      return mes.from == source && mes.nonce == fromNonce;
    }).toList();
  }

  void speedUp() {
    var msg = Global.provider.getIncreaseGasMessage(nonce: fromNonce);
    $store.setPushBackPage(mainPage);
    Get.toNamed(mesBodyPage, arguments: {
      'mes': msg,
    });
  }

  void makeNew(BuildContext context, state) async {
    var list = OpenedBox.pushInsance.values
        .where((mes) => mes.from == fromCtrl.text.trim());
    var nonce = fromNonce;
    list.forEach((mes) {
      if (mes.nonce != null && mes.nonce > nonce) {
        nonce = mes.nonce as int;
      }
    });
    var res = await makeMessage(state);
    if (res is TMessage) {
      res.nonce = nonce + 1;
      addOperation('make_mes');
      unFocusOf(context);
      goConfirm(res);
      // $store.setPushBackPage(mainPage);
      // Get.toNamed(mesBodyPage, arguments: {
      //   'mes': res,
      // });
    }
  }

  void goConfirm(TMessage mes) {
    $store.setConfirmMessage(mes);
    Get.toNamed(mesConfirmPage,
        arguments: {'title': 'first'.tr, 'footer': 'build'.tr});
  }

  @override
  void initState() {
    super.initState();

    var args = Get.arguments;
    if (args != null) {
      var mesType = args['type'] as MessageType;
      switch (mesType) {
        case MessageType.OwnerTransfer:
          fromCtrl.text = Get.arguments['from'] as String;
          break;
        case MessageType.MinerManage:
          //fromCtrl.text = Get.arguments['from'];
          var list = OpenedBox.minerAddressInstance.values
              .where((addr) =>
                  addr.type == 'owner' &&
                  addr.miner == $store.wal.addressWithNet)
              .toList();
          if (list.isNotEmpty) {
            var owner = list[0].address;
            if (owner.trim()[1] == '2') {
              preventNext = true;
              nextTick(() {
                showCustomError('ownerIsMulti'.tr);
              });
            }
            fromCtrl.text = list[0].address;
          }
          toCtrl.text = Get.arguments['to'] as String;
          // valueCtrl.text = '0';
          String method = Get.arguments['method'] as String;
          methods = Get.arguments['method'] as String;
          showTips = true;
          if (method == '16') {
            getMinerBalance(Get.arguments['to'] as String);
          }
          break;
        default:
      }
      var origin = args['origin'];
      if (origin != null) {
        this.showFrom = false;
        fromCtrl.text = wallet.addressWithNet;
      }
      if (fromCtrl.text != '') {
        var addr = fromCtrl.text;
        getFromBalance(addr);
        if (addr[1] == '0') {
          this.getFromType(addr);
        }
      }
    }
    sub = Global.eventBus.on<GasConfirmEvent>().listen((event) {
      $store.setPushBackPage(mainPage);
      Get.toNamed(mesBodyPage, arguments: {
        'mes': $store.confirmMes,
      });
    });
  }

  // void changeMethod(String method) {
  //   this.method = method;
  // }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  Future getFromBalance(String addr) async {
    var res = await Global.provider.getBalanceNonce(fromCtrl.text);
    try {
      var balance = BigInt.tryParse(res.balance);
      fromBalance = balance ?? BigInt.zero;
      fromNonce = res.nonce as int;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void getFromType(String addr) async {
    try {
      var res = await Global.provider.getAddressType(addr);
      if (res == FilecoinAddressType.multisig) {
        this.preventNext = true;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getMinerBalance(String addr) async {
    try {
      var res = await Global.provider.getBalance(addr);
      minerBalance = BigInt.tryParse(res) ?? BigInt.zero;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    var keyH = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
        create: (context) => MakeBloc()..add(SetMakeEvent(method: methods)),
        child: BlocBuilder<MakeBloc, MakeState>(builder: (context, state) {
          return CommonScaffold(
            title: 'first'.tr,
            footerText: 'next'.tr,
            actions: [
              ScanAction(handleScan: () {
                Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
                    .then((scanResult) {
                  if (scanResult != '') {
                    if (!isValidAddress(scanResult as String)) {
                      showCustomError('wrongAddr'.tr);
                    }
                    toCtrl.text = scanResult as String;
                  }
                });
              })
            ],
            body: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      12, 20, 12, state.method == '3' ? keyH + 20 : 20),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          AdvancedSet(
                            method: state.method,
                            label: 'messageType'.tr,
                            onChange: (String v) {
                              BlocProvider.of<MakeBloc>(context)
                                  .add(SetMakeEvent(method: v));
                              setState(() {
                                if (state.method == '3' ||
                                    state.method == '23') {
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
                                onChanged: (addr) {
                                  if (isValidAddress(addr)) {
                                    getFromBalance(addr);
                                    if (addr[1] == '0') {
                                      this.getFromType(addr);
                                    }
                                  }
                                },
                                extra: GestureDetector(
                                  child: Padding(
                                    child: Image(
                                        width: 20,
                                        image: AssetImage('images/book.png')),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onTap: () {
                                    Get.toNamed(addressSelectPage)
                                        .then((value) {
                                      if (value != null) {
                                        fromCtrl.text =
                                            (value as Wallet).address;
                                        if (isValidAddress(fromCtrl.text)) {
                                          var addr = fromCtrl.text;
                                          getFromBalance(addr);
                                          if (addr[1] == '0') {
                                            this.getFromType(addr);
                                          }
                                        }
                                      }
                                    });
                                  },
                                ),
                              )),
                          Visibility(
                              visible: state.method != '2',
                              child: Field(
                                label: state.method == '0'
                                    ? 'to'.tr
                                    : 'minerAddr'.tr,
                                controller: toCtrl,
                                extra: GestureDetector(
                                  child: Padding(
                                    child: Image(
                                        width: 20,
                                        image: AssetImage('images/book.png')),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onTap: () {
                                    Get.toNamed(addressSelectPage)
                                        .then((value) {
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
                                type: TextInputType.numberWithOptions(
                                    decimal: true),
                                // append: CommonText(
                                //     formatFil($store.wal.balance)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9.]"))
                                ]),
                            visible:
                                state.method == '0' || state.method == '16',
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Visibility(
                                visible: state.method == '23',
                                child: Field(
                                  label: 'owner'.tr,
                                  controller: ownerCtrl,
                                ),
                              ),
                              Visibility(
                                child: ChangeWorkerAddress(
                                  worker: worker,
                                  controllers: state.controllers,
                                  add: () => addController(context),
                                  remove: (index) =>
                                      removeController(context, index),
                                ),
                                visible: state.method == '3',
                              ),
                              Visibility(
                                  visible: state.method == '2',
                                  child: CreateMiner(
                                      workerController: worker,
                                      onChange: (v) {
                                        BlocProvider.of<MakeBloc>(context)
                                            .add(SetMakeEvent(sealType: v));
                                      },
                                      sealType: state.sealType))
                            ],
                          ),
                          Visibility(
                            child: Tips(['minerManageTip'.tr]),
                            visible: showTips,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          DocButton(
                            method: state.method,
                            page: mesMakePage,
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
                makeNewOrSpeed(state);
              } else {
                handleSubmit(context, state);
              }
            },
          );
        }));
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText(
                  MethodMap.getMethodNameByNum(method) ?? '',
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
              int.parse(value as String);
              onChange(value as String);
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
  final ValueChanged<int> remove;
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
                  if (scanResult != '' &&
                      isValidAddress(scanResult as String)) {
                    worker.text = scanResult as String;
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
                          if (scanResult != '' &&
                              isValidAddress(scanResult as String)) {
                            ctrl.text = scanResult as String;
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
  final ValueChanged<String> onChange;
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
                if (scanResult != '' && isValidAddress(scanResult as String)) {
                  workerController.text = scanResult as String;
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
