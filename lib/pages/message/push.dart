import 'dart:convert';
import 'package:fil/api/update.dart';
import 'package:fil/bloc/push/push_bloc.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/pages/sign/signBody.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/button.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/dialog.dart';
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
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// push signed message to lotus node
class MesPushPage extends StatefulWidget {
  @override
  State createState() => MesPushPageState();
}

/// page of message push
class MesPushPageState extends State<MesPushPage> {
  TextEditingController controller = TextEditingController();
  Gas gas;
  int tryDecodeCount = 3;
  var map = <String, String>{
    '0': FilecoinMethod.send,
    '3': FilecoinMethod.changeWorker,
    '16': FilecoinMethod.withdraw,
    '21': FilecoinMethod.confirmUpdateWorkerKey,
    '23': FilecoinMethod.changeOwner,
  };

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
          m.methodName = map[mes.method.toString()];
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
          } else {
            decodeParams(mes, cid);
          }
        }
        if (mes.method == 3) {
          if (!OpenedBox.multiInsance.containsKey(mes.to)) {
            m.methodName = FilecoinMethod.changeWorker;
            OpenedBox.messageInsance.put(cid, m);
          } else {
            decodeParams(mes, cid);
          }
        }
      }
    }
  }

  void decodeParams(TMessage mes, String cid) async {
    if (tryDecodeCount == 0) {
      return;
    }
    try {
      var res = await Global.provider.decodeParams(
          {'to': mes.to, 'method': mes.method, 'params': mes.params});
      if (res['params_json'] is String) {
        var args = jsonDecode(res['params_json'] as String);
        if (mes.method == 2) {
          var method = args['Method'].toString();
          if (map.containsKey(method)) {
            var multiMes = CacheMultiMessage(
              from: mes.from,
              to: mes.to,
              pending: 1,
              owner: mes.from,
              nonce: mes.nonce as int,
              method: map[method],
              params: res['params_json'] as String,
              fee: mes.maxFee.toString(),
              blockTime: getSecondSinceEpoch(),
              innerParams: res['params_params_json'] as String,
            );
            OpenedBox.multiProposeInstance.put(cid, multiMes);
          }
        }
        if (mes.method == 3) {
          var txId = args['ID'];
          var proposalList = OpenedBox.multiProposeInstance.values
              .where((m) => m.to == mes.to && m.txId == txId)
              .toList();
          if (proposalList.length == 1) {
            var proposal = proposalList[0];
            OpenedBox.multiApproveInstance.put(
                cid,
                MultiApproveMessage(
                    proposeCid: mes.args,
                    cid: cid,
                    from: mes.from,
                    txId: proposal.txId,
                    fee: mes.maxFee.toString(),
                    nonce: mes.nonce as int,
                    time: getSecondSinceEpoch()));
          }
        }
      }
    } catch (e) {
      print(e);
      tryDecodeCount--;
      decodeParams(mes, cid);
    }
  }

  void handlePush(BuildContext context, SignedMessage message,
      {bool checkGas = true}) async {
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
        addOperation('push_mes');
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

  void handleScan(BuildContext context) {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.SignedMessage})
        .then((scanResult) {
      if (scanResult != '') {
        try {
          var result = jsonDecode(scanResult as String);
          SignedMessage message =
              SignedMessage.fromJson(result as Map<String, dynamic>);
          if (message.message.valid) {
            // getGas(message.message);
            BlocProvider.of<PushBloc>(context)
                .add(SetPushEvent(message: message, showDisplay: true));
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

  void showDetail(BuildContext context, SignedMessage message) {
    BlocProvider.of<PushBloc>(context)
        .add(SetPushEvent(message: message, showDisplay: true));
  }

  void showGasDialog(BuildContext context) {
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
                      // handlePush(context, checkGas: false);
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
    return BlocProvider(
        create: (context) => PushBloc()..add(SetPushEvent()),
        child: BlocBuilder<PushBloc, PushState>(builder: (context, state) {
          return CommonScaffold(
            title: 'third'.tr,
            footerText: 'push'.tr,
            onPressed: () {
              if (!state.showDisplay) {
                return;
              }
              handlePush(context, state.message, checkGas: true);
            },
            actions: [ScanAction(handleScan: () => handleScan(context))],
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
                  state.showDisplay
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
                                              copyText(jsonEncode(state.message
                                                  .toLotusSignedMessage()));
                                              showCustomToast('copySucc'.tr);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(20),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[200]),
                                                  borderRadius:
                                                      CustomRadius.b6),
                                              child: CommonText(JsonEncoder
                                                      .withIndent(' ')
                                                  .convert(state.message
                                                      .toLotusSignedMessage())),
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  );
                                });
                          },
                          message: state.message.message,
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
                              onTap: () => handleScan(context),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var data = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                var result = data.text;
                                var valid = result.indexOf('Message') > 0 &&
                                    result.indexOf('Signature') > 0;
                                if (!valid) {
                                  showCustomError('copyErrorMes'.tr);
                                  return;
                                }
                                try {
                                  var res = jsonDecode(result);
                                  SignedMessage message =
                                      SignedMessage.fromJson(
                                          res as Map<String, dynamic>);
                                  if (message.message.valid) {
                                    // getGas(message.message);
                                    BlocProvider.of<PushBloc>(context).add(
                                        SetPushEvent(
                                            message: message,
                                            showDisplay: true));
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
                    visible: !state.showDisplay,
                  )
                ]),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20)),
          );
        }));
  }
}
