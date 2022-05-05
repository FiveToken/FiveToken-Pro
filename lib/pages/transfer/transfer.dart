import 'dart:async';
import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/formatter.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

/// transfer page
class FilTransferNewPage extends StatefulWidget {
  @override
  State createState() => FilTransferNewPageState();
}

/// page of transfer
class FilTransferNewPageState extends State<FilTransferNewPage> {
  String balance;
  TextEditingController _amountCtrl = TextEditingController();
  TextEditingController _addressCtrl = TextEditingController();
  StoreController controller = $store;
  int nonce;
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  StreamSubscription sub;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['to'] != null) {
      _addressCtrl.text = Get.arguments['to'] as String;
    }
    Global.provider.prepareNonce();
    sub = Global.eventBus.on<GasConfirmEvent>().listen((event) {
      handleConfirm();
    });
  }

  BigInt get fromBalance => BigInt.tryParse($store.wal.balance) ?? BigInt.zero;
  @override
  void dispose() {
    super.dispose();
    _amountCtrl.dispose();
    _addressCtrl.dispose();
    sub.cancel();
  }

  /// increase gas and resend a blocked message
  void speedup(String private) async {
    try {
      await Global.provider.speedup(private: private);
      Navigator.popUntil(context, (route) => route.settings.name == mainPage);
    } catch (e) {
      showCustomError(e.toString());
    }
  }

  /// push message
  void pushMsg(String ck, {bool increaseNonce = false}) async {
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    try {
      await Global.provider.sendMessage(
          message: $store.confirmMes,
          increaseNonce: increaseNonce,
          private: ck,
          callback: (res) {
            Get.offAndToNamed(mainPage);
            // Navigator.popUntil(context, (route) => route.settings.name == mainPage);
          });
    } catch (e) {
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  /// check valid of valid
  bool checkInputValid() {
    var amount = _amountCtrl.text;
    var toAddress = _addressCtrl.text;
    var trimAmount = amount.trim();
    var trimAddress = toAddress.trim();
    if (trimAddress == "") {
      showCustomError('enterTo'.tr);
      return false;
    }
    if (!isValidAddress(trimAddress)) {
      showCustomError('errorAddr'.tr);
      return false;
    }
    if (trimAddress == $store.wal.addr) {
      showCustomError('errorFromAsTo'.tr);
      return false;
    }
    if (trimAmount == "" || !isDecimal(trimAmount)) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var a = double.parse(trimAmount);
    if (a == 0) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var n = Decimal.parse(a.toString()) * Decimal.fromInt(pow(10, 18).toInt());
    if (fromBalance <= BigInt.from(n.toDouble())) {
      showCustomError('errorLowBalance'.tr);
      return false;
    }
    return true;
  }

  /// estimate gas
  void estimateGas() async {
    try {
      var from = $store.addr;
      var to = _addressCtrl.text.trim();
      var value = fil2Atto(_amountCtrl.text.trim());
      showCustomLoading('getGas'.tr);
      var gas = await Global.provider.estimateGas(
          {'from': from, 'to': to, 'value': value, 'params': null});
      dismissAllToast();
      var message = TMessage(
        from: from,
        to: to,
        value: value,
        nonce: $store.nonce,
      );
      var balance = BigInt.tryParse($store.wal.balance);
      var fee = message.maxFee;
      if (balance <= fee) {
        showCustomError('errorLowBalance'.tr);
        return;
      }

      /// set message gas
      message.setGas(gas);
      $store.setConfirmMessage(message);
      Get.toNamed(mesConfirmPage,
          arguments: {'title': 'send'.tr, 'footer': 'send'.tr});
    } catch (e) {
      showCustomError('getGasFail'.tr);
    }
  }

  /// handle scan
  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult as String)) {
          _addressCtrl.text = scanResult as String;
        } else {
          showCustomError('errorAddr'.tr);
        }
      }
    });
  }

  /// handle confirm
  void handleConfirm() {
    var pushNew = (bool increaseNonce) {
      showPassDialog(context, (String pass) async {
        var wal = $store.wal;
        var address = wal.addressWithNet;
        var ck = await decryptSodium(wal.skKek, address, pass);
        pushMsg(ck, increaseNonce: increaseNonce);
      });
    };
    Global.provider.checkSpeedUpOrMakeNew(
        context: context,
        onNew: (bool increaseNonce) {
          pushNew(increaseNonce);
        },
        nonce: $store.nonce,
        onSpeedup: () async {
          showPassDialog(context, (String pass) async {
            var wal = $store.wal;
            var address = wal.addressWithNet;
            var ck = await decryptSodium(wal.skKek, address, pass);
            speedup(ck);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'send'.tr,
      footerText: 'next'.tr,
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
      onPressed: () async {
        if (!checkInputValid()) {
          return;
        }
        if (!$store.canPush) {
          showCustomLoading('getNonce'.tr);
          var valid = await Global.provider.prepareNonce();
          dismissAllToast();
          if (valid) {
            estimateGas();
          } else {
            showCustomError('errorGetNonce'.tr);
          }
        } else {
          estimateGas();
        }
      },
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Field(
              controller: _addressCtrl,
              label: 'to'.tr,
              extra: GestureDetector(
                child: Padding(
                  child: Image(width: 20, image: AssetImage('images/book.png')),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onTap: () {
                  Get.toNamed(addressSelectPage).then((value) {
                    if (value != null) {
                      var addr = (value as Wallet).address;
                      _addressCtrl.text = addr;
                    }
                  });
                },
              ),
            ),
            Field(
              controller: _amountCtrl,
              type: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PrecisionLimitFormatter(18)],
              label: 'amount'.tr,
              append: Obx(() => CommonText(
                    formatFil(controller.wal.balance),
                    color: CustomColor.grey,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

/// widget of speed up sheet
class SpeedupSheet extends StatelessWidget {
  final Noop onSpeedUp;
  final Noop onNew;
  SpeedupSheet({this.onSpeedUp, this.onNew});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('hasPending'.tr),
                SizedBox(
                  height: 15,
                ),
                TapCard(
                  items: [
                    CardItem(
                      label: 'speedup'.tr,
                      onTap: () {
                        Get.back();
                        onSpeedUp();
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
                      label: 'continueNew'.tr,
                      onTap: () {
                        Get.back();
                        onNew();
                      },
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

/// widget of confirm sheet
class ConfirmSheet extends StatelessWidget {
  final TMessage message;
  final String from;
  final String to;
  final String gas;
  final String value;
  final SingleStringParamFn onConfirm;
  final Widget footer;
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ConfirmSheet(
      {this.from,
      this.to,
      this.gas,
      this.value,
      this.onConfirm,
      this.footer,
      this.message});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
          color: CustomColor.bgGrey,
          child: Column(
            children: [
              Container(
                padding: padding,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('from'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          message.from,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('to'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          message.to,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText.grey('amount'.tr),
                    CommonText(
                      formatFil(message.value, returnRaw: true),
                      size: 18,
                      color: CustomColor.primary,
                      weight: FontWeight.w500,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText.grey('fee'.tr),
                    CommonText.main(formatFil(message.maxFee.toString()))
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 30,
              ),
              footer ??
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(const Radius.circular(8)),
                      color: CustomColor.primary,
                    ),
                    child: FlatButton(
                      child: Text(
                        'send'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var address = wal.addressWithNet;
                          var ck =
                              await decryptSodium(wal.skKek, address, pass);
                          onConfirm(ck);
                        });
                      },
                      //color: Colors.blue,
                    ),
                  )
            ],
          ),
          padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
        )
      ],
    );
  }
}
