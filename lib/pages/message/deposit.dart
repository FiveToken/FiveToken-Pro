import 'dart:async';
import 'package:fil/bloc/message/message_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/other.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

/// miner deposit
class DepositPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DepositPageState();
  }
}

/// page of deposit
class DepositPageState extends State<DepositPage> {
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  TextEditingController valueCtrl = TextEditingController();
  TextEditingController methodCtrl = TextEditingController();
  bool fromEnabled = true;
  num nonce;
  StreamSubscription sub;
  @override
  void initState() {
    super.initState();
    methodCtrl.text = 'Transfer (0)';
    if (Get.arguments != null) {
      toCtrl.text = Get.arguments['to'] as String ?? "";
    }

    sub = Global.eventBus.on<GasConfirmEvent>().listen((event) {
      if (_state.radioType == RechargeRadio.offLine) {
        $store.setPushBackPage(mainPage);
        Get.toNamed(mesBodyPage, arguments: {'mes': $store.confirmMes});
      } else {
        var wal = OpenedBox.addressInsance.get(fromCtrl.text.trim());
        showPassDialog(context, (String pass) async {
          var msg = $store.confirmMes;
          var address = wal.addressWithNet;
          var private = await decryptSodium(wal.skKek, address, pass);
          try {
            await Global.provider.sendMessage(
                message: msg,
                private: private,
                callback: (res) {
                  Get.back();
                });
          } catch (e) {
            print(e);
            showCustomError(getErrorMessage(e.toString()));
          }
        }, from: wal);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  void handleTypeChange(BuildContext context, String value) {
    BlocProvider.of<MessageBloc>(context).add(setRadioTypeEvent(value));
    if (value == RechargeRadio.onLine) {
      fromCtrl.text = '';
      fromEnabled = false;
    } else {
      fromEnabled = true;
    }
  }

  void confirm(String type) async {
    var from = fromCtrl.text.trim();
    var to = toCtrl.text;
    var value = valueCtrl.text.trim();
    try {
      double.parse(value);
      value = fil2Atto(value);
    } catch (e) {
      showCustomError('enterValidAmount'.tr);
      return;
    }
    if (from == '' || value == '') {
      showCustomError('missField'.tr);
      return;
    }
    if (type == RechargeRadio.offLine) {
      var res = await Global.provider
          .buildMessage({'from': from, 'to': to, 'value': value, 'method': 0});
      if (res.value != null) {
        unFocusOf(context);
        $store.setConfirmMessage(res);
        Get.toNamed(mesConfirmPage,
            arguments: {'title': 'first'.tr, 'footer': 'build'.tr});
      }
    } else {
      if (!$store.canPush) {
        showCustomLoading('Loading');
        var valid = await Global.provider.prepareNonce(to: from);
        dismissAllToast();
        if (!valid) {
          showCustomError('errorSetGas'.tr);
          return;
        }
      }
      try {
        showCustomLoading('getGas'.tr);
        var gas = await Global.provider.estimateGas({
          'from': from,
          'to': to,
          'params': "",
          'value': value,
        });
        dismissAllToast();
        var message = TMessage(
          version: 0,
          method: 0,
          nonce: $store.nonce,
          from: from,
          to: to,
          params: "",
          value: value,
        );
        message.setGas(gas);
        $store.setConfirmMessage(message);
        Get.toNamed(mesConfirmPage, arguments: {
          'title': 'depositRecharge'.tr,
          'footer': 'depositRecharge'.tr
        });
      } catch (e) {
        showCustomError('getGasFail'.tr);
      }
    }
  }

  void showWallet(String type) {
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
              child: Column(
                children: [
                  Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(8)),
                        color: CustomColor.primary),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Image(
                            width: 20,
                            image: AssetImage('images/close.png'),
                          ),
                          onTap: () {
                            Get.back();
                          },
                        ),
                        CommonText('selectWallet'.tr, color: Colors.white),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: WalletSelect(
                    filterType:
                        type != RechargeRadio.offLine ? 'hd' : 'readonly',
                    onTap: (Wallet wallet) {
                      var from = wallet.addressWithNet;
                      Get.back();
                      fromCtrl.text = from;
                      if (type == RechargeRadio.onLine) {
                        Global.provider.prepareNonce(from: from);
                      }
                    },
                  ))
                ],
              ),
              constraints: BoxConstraints(maxHeight: 800));
        });
  }

  var _state;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageBloc(),
        child:
            BlocBuilder<MessageBloc, MessageState>(builder: (context, state) {
          _state = state;
          return CommonScaffold(
            title: state.radioType == RechargeRadio.offLine
                ? 'mesMake'.tr
                : 'depositRecharge'.tr,
            onPressed: () {
              confirm(state.radioType);
            },
            actions: [
              ScanAction(handleScan: () {
                Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
                    .then((scanResult) {
                  if (scanResult != '') {
                    if (!isValidAddress(scanResult as String)) {
                      showCustomError('wrongAddr'.tr);
                    }
                    fromCtrl.text = scanResult as String;
                  }
                });
              })
            ],
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        BoldText(
                          'select'.tr,
                        ),
                        Spacer(),
                        Radio(
                            activeColor: CustomColor.primary,
                            value: RechargeRadio.offLine,
                            groupValue: state.radioType,
                            onChanged: (value) {
                              String type = value as String;
                              handleTypeChange(context, type);
                            }),
                        Text('off'.tr),
                        Radio(
                          activeColor: CustomColor.primary,
                          value: RechargeRadio.onLine,
                          groupValue: state.radioType,
                          onChanged: (value) {
                            String type = value as String;
                            handleTypeChange(context, type);
                          },
                        ),
                        Text('on'.tr)
                      ],
                    ),
                  ),
                  Field(
                    controller: fromCtrl,
                    label: 'from'.tr,
                    enabled: fromEnabled,
                    extra: GestureDetector(
                        child: Padding(
                          child: Image(
                              width: 20, image: AssetImage('images/book.png')),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onTap: () {
                          showWallet(state.radioType);
                        }),
                  ),
                  Field(
                    controller: toCtrl,
                    label: 'to'.tr,
                    enabled: false,
                  ),
                  Field(
                    controller: methodCtrl,
                    label: 'method'.tr,
                    enabled: false,
                  ),
                  Field(
                      label: 'amount'.tr,
                      controller: valueCtrl,
                      type: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                      ]),
                  state.radioType == '1' ? Tips(['depositDes'.tr]) : Container()
                ],
              ),
              padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
            ),
            footerText: 'next'.tr,
          );
        }));
  }
}

class Tips extends StatelessWidget {
  final List<String> content;
  Tips(this.content);
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      CommonText(
        'depositTips'.tr,
      ),
      Divider(),
    ];
    content.forEach((element) {
      children.add(CommonText(
        element,
        size: 12,
        color: Colors.grey[500],
      ));
    });
    return Container(
      color: Colors.grey[200],
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
