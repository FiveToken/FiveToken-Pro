import 'dart:async';
import 'dart:convert';
import 'package:fbutton/fbutton.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/button.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

/// create a multi-sig wallet
class MultiCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiCreatePageState();
  }
}

/// page of multi create
class MultiCreatePageState extends State<MultiCreatePage> {
  TextEditingController labelCtrl = TextEditingController();
  TextEditingController signerCtrl = TextEditingController();
  TextEditingController thresholdCtrl = TextEditingController();
  List<TextEditingController> signers = [TextEditingController()];
  int singerNum = 0;
  int nonce;
  StreamSubscription sub;
  String params;
  @override
  void initState() {
    super.initState();
    signerCtrl.text = $store.wal.address;
    Global.provider.prepareNonce();
    sub = Global.eventBus.on<GasConfirmEvent>().listen((event) {
      handleConfirm();
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  String get from {
    return $store.wal.addressWithNet;
  }

  List<String> get signerAddrs {
    var signerAddrs = [from];
    signers.forEach((ctrl) {
      var s = ctrl.text.trim();
      signerAddrs.add(s);
    });
    return signerAddrs;
  }

  Future getSerializeParams() async {
    var threshold = int.parse(thresholdCtrl.text.trim());
    var params = {
      'signers': signerAddrs,
      'threshold': threshold,
      'unlock_duration': 0
    };

    /// serialize create params
    var p = await Global.provider.getSerializeParams(params);
    this.params = p;
  }

  void pushMessage(String pass) async {
    var threshold = int.parse(thresholdCtrl.text.trim());
    TMessage msg = $store.confirmMes;
    var wal = $store.wal;
    var address = wal.addressWithNet;
    var private = await decryptSodium(wal.skKek, address, pass);
    try {
      await Global.provider.sendMessage(
          message: msg,
          private: private,
          methodName: FilecoinMethod.exec,
          callback: (res) {
            OpenedBox.multiInsance.put(
                res,
                MultiSignWallet(
                    cid: res,
                    blockTime: getSecondSinceEpoch(),
                    label: labelCtrl.text.trim(),
                    threshold: threshold,
                    signers: signerAddrs));
            Navigator.popUntil(
                context, (route) => route.settings.name == mainPage);
          });
    } catch (e) {
      print(e);
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  void handleConfirm() async {
    if ($store.wal.readonly == 1) {
      TMessage msg = $store.confirmMes;
      $store.setPushBackPage(mainPage);
      var cid = await Flotus.genCid(msg: jsonEncode(msg.toLotusMessage()));
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

  bool checkValid() {
    var label = labelCtrl.text.trim();
    var threshold = thresholdCtrl.text.trim();
    var thresholdNum = 0;
    if (label == '') {
      showCustomError('enterName'.tr);
      return false;
    }
    try {
      var n = int.parse(threshold);
      thresholdNum = n;
    } catch (e) {
      showCustomError('errorThreshold'.tr);
      return false;
    }
    if (thresholdNum > signers.length + 1) {
      showCustomError('bigThreshold'.tr);
      return false;
    }
    var allAddrValid = true;
    for (var i = 0; i < signers.length; i++) {
      var addr = signers[i].text.trim();
      if (!isValidAddress(addr)) {
        allAddrValid = false;
        break;
      }
    }
    return allAddrValid;
  }

  void handleNext() async {
    if (!checkValid()) {
      return;
    }
    var handle = () async {
      try {
        showCustomLoading('getGas'.tr);
        await getSerializeParams();
        var gas = await Global.provider.estimateGas({
          'from': from,
          'to': FilecoinAccount.f01,
          'value': '0',
          'method': MethodTypeOfMessage.proposal,
          'params': this.params,
          'encoded': true
        });
        dismissAllToast();
        var msg = TMessage(
          method: MethodTypeOfMessage.proposal,
          nonce: $store.nonce,
          from: from,
          to: FilecoinAccount.f01,
          params: this.params,
          value: '0',
        );
        msg.setGas(gas);
        var balance = BigInt.tryParse($store.wal.balance) ?? BigInt.zero;
        if (msg.maxFee >= balance) {
          showCustomError('errorLowBalance'.tr);
          return;
        }
        $store.setConfirmMessage(msg);
        Get.toNamed(mesConfirmPage,
            arguments: {'title': 'createMulti'.tr, 'footer': 'create'.tr});
      } catch (e) {
        showCustomLoading('getGasFail'.tr);
      }
    };
    if (!$store.canPush) {
      await Global.provider.prepareNonce();
      handle();
    } else {
      handle();
    }
  }

  @override
  Widget build(BuildContext context) {
    var keyH = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      title: 'createMulti'.tr,
      footerText: 'create'.tr,
      onPressed: () {
        handleNext();
      },
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 20, 12, keyH + 20),
              physics: BouncingScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      height: 55,
                      padding: EdgeInsets.fromLTRB(12, 0, 15, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: CommonText(
                            $store.wal.address,
                            size: 16,
                          )),
                          SizedBox(
                            width: 15,
                          ),
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
                                    child: Icon(
                                      Icons.portrait_outlined,
                                      size: 22,
                                      color: Color.fromRGBO(0, 0, 0, .7),
                                    ),
                                    onTap: () {
                                      Get.toNamed(addressSelectPage)
                                          .then((value) {
                                        if (value != null) {
                                          signers[index].text =
                                              (value as Wallet).address;
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Get.toNamed(scanPage, arguments: {
                                          'scene': ScanScene.Address
                                        }).then((scanResult) {
                                          if (scanResult != '' &&
                                              isValidAddress(
                                                  scanResult as String)) {
                                            signers[index].text =
                                                scanResult as String;
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
                      height: 20,
                    ),
                    DocButton(
                      page: multiCreatePage,
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: 120,
          )
        ],
      ),
    );
  }
}
