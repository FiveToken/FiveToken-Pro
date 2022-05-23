import 'dart:async';
import 'dart:convert';
import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/time.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

/// display infomation of the proposal or approval
class MultiProposalDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiProposalDetailPageState();
  }
}

/// page of mutil proposal detail
class MultiProposalDetailPageState extends State<MultiProposalDetailPage> {
  CacheMultiMessage msg = CacheMultiMessage();
  bool needApprove = false;
  List<MultiApproveMessage> approves = [];
  String proposer;
  String actorId = '';
  MultiSignWallet wallet = $store.multiWal;
  int txid;
  String to = '';
  String value = '0';
  int method = 0;
  dynamic params;
  String footerText = 'approve'.tr;
  StreamSubscription sub;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      msg = Get.arguments['msg'] as CacheMultiMessage;
      proposer = msg.from;
      var pendingApproves = OpenedBox.multiApproveInstance.values
          .where((apr) => apr.proposeCid == msg.cid)
          .toList();
      var completeApproves = msg.approves;

      needApprove = msg.pending == 0 &&
          msg.exitCode == 0 &&
          $store.wal.addr != msg.from &&
          completeApproves
              .where((apr) => apr.exitCode == 0 && apr.from == $store.addr)
              .isEmpty;
      approves
        ..addAll(pendingApproves)
        ..addAll(msg.approves)
        ..sort((a, b) {
          if (a.time != null && b.time != null) {
            return a.time.compareTo(b.time);
          } else {
            return 1;
          }
        });
      if (needApprove) {
        var failList = completeApproves
            .where((mes) => mes.from == $store.addr && mes.exitCode != 0);
        if (failList.isNotEmpty) {
          footerText = 'reapprove'.tr;
        }
        Global.provider.prepareNonce();
        sub = Global.eventBus.on<GasConfirmEvent>().listen((event) {
          handleConfirm();
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  Future<String> genParams() async {
    var transactionInput = {
      'tx_id': msg.txId,
      'requester': actorId,
      'to': msg.decodeParams['To'],
      'value': msg.decodeParams['Value'],
      'method': msg.decodeParams['Method'],
      'params': msg.decodeParams['Params'],
    };
    var str = jsonEncode(transactionInput);
    var p = await Flotus.genApprovalV3(str);
    var decodeParams = jsonDecode(p);
    return decodeParams['param'] as String;
  }

  void pushMessage(String pass, {bool increaseNonce}) async {
    var message = $store.confirmMes;
    var wal = $store.wal;
    var address = wal.addressWithNet;
    var private = await decryptSodium(wal.skKek, address, pass);
    try {
      await Global.provider.sendMessage(
          message: message,
          private: private,
          multiId: wallet.id,
          increaseNonce: increaseNonce,
          callback: (res) {
            OpenedBox.multiApproveInstance.put(
                res,
                MultiApproveMessage(
                    proposeCid: msg.cid,
                    cid: res,
                    from: $store.addr,
                    txId: txid,
                    fee: message.maxFee.toString(),
                    nonce: message.nonce as int,
                    time: getSecondSinceEpoch()));
            Navigator.popUntil(
                context, (route) => route.settings.name == multiMainPage);
          });
    } catch (e) {
      print(e);
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  void handleConfirm() {
    if ($store.wal.readonly == 1) {
      var msg = $store.confirmMes;
      msg.args = this.msg.cid;
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
              var address = wal.addressWithNet;
              var private = await decryptSodium(wal.skKek, address, pass);
              try {
                await Global.provider.speedup(
                    private: private, methodName: FilecoinMethod.approve);
                Get.back();
              } catch (e) {
                showCustomError(e.toString());
              }
            });
          });
    }
  }

  void handleNext() async {
    if (proposer.substring(1) == $store.wal.addr.substring(1)) {
      showCustomError('sameAsSigner'.tr);
      return;
    }
    if (!$store.canPush) {
      var valid = await Global.provider.prepareNonce();
      if (!valid) {
        showCustomError('errorGetNonce'.tr);
        return;
      }
    }

    if (actorId == '') {
      var res = await Global.provider.getMultiInfo($store.multiWallet.value.id);
      if (!res.signerMap.containsKey(proposer)) {
        showCustomError('getActorFailed'.tr);
        return;
      } else {
        actorId = res.signerMap[proposer];
      }
    }
    var params = await genParams();
    try {
      showCustomLoading('getGas'.tr);
      var gas = await Global.provider.estimateGas({
        'method': MethodTypeOfMessage.proposalDetail,
        'from': $store.addr,
        'to': wallet.id,
        'params': params,
        'value': '0',
        'encoded': true
      });
      dismissAllToast();
      var message = TMessage(
        method: MethodTypeOfMessage.proposalDetail,
        nonce: $store.nonce,
        from: $store.wal.addr,
        to: wallet.id,
        params: params,
        value: '0',
      );
      message.setGas(gas);
      var balanceNum = BigInt.tryParse($store.wal.balance) ?? BigInt.zero;
      var feeNum = message.maxFee;
      if (balanceNum <= feeNum) {
        showCustomError('errorLowBalance'.tr);
        return;
      }
      $store.setConfirmMessage(message);
      Get.toNamed(mesConfirmPage, arguments: {
        'title': 'approve'.tr,
        'footer': 'approve'.tr,
      });
    } catch (e) {
      showCustomError('getGasFail'.tr);
    }
  }

  String get methodName => msg.method;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'next'.tr,
      hasFooter: needApprove,
      onPressed: () {
        handleNext();
      },
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      MultiMessageStatusHeader(msg, ''),
                      SizedBox(
                        height: 25,
                      ),
                      Visibility(child: MultiParams(msg), visible: true),
                      CommonCard(Column(
                        children: [
                          Visibility(
                            child: MultiMessageRow(
                              label: 'proposeId'.tr,
                              value: msg.txId.toString(),
                            ),
                            visible: msg.completed,
                          ),
                          MultiMessageRow(
                            label: 'proposeAddr'.tr,
                            append: ApproveStatus(
                                address: msg.from,
                                fee: msg.fee,
                                pending: msg.pending,
                                cid: msg.cid,
                                ok: msg.exitCode == 0,
                                time: msg.blockTime),
                          ),
                          Column(
                            children: List.generate(approves.length, (index) {
                              var approve = approves[index];
                              return MultiMessageRow(
                                  label: 'approveAddr'.tr,
                                  append: ApproveStatus(
                                      address: approve.from,
                                      fee: approve.fee,
                                      pending: approve.pending,
                                      cid: approve.cid,
                                      ok: approve.exitCode == 0,
                                      time: approve.time));
                            }),
                          ),
                        ],
                      )),
                      Visibility(
                          visible: msg.exitCode != 0,
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(multiProposalPage, arguments: {
                                'innerParams': msg.decodeInnerParams,
                                'params': msg.decodeParams
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CommonText('repropose'.tr,
                                  color: CustomColor.primary),
                            ),
                          )),
                    ],
                  ))),
          SizedBox(
            height: needApprove ? 120 : 0,
          )
        ],
      ),
      footerText: footerText,
    );
  }
}

class MultiMessageStatusHeader extends StatelessWidget {
  final CacheMultiMessage mes;
  final String label;
  MultiMessageStatusHeader(this.mes, this.label);
  bool get pending {
    return mes.pending == 1;
  }

  Map<String, dynamic> get data {
    if (mes.pending == 1) {
      return {
        'image': 'images/pending-res.png',
        'label': 'proposePending'.tr,
        'color': Color(0xffE8CC5C)
      };
    } else {
      if (mes.exitCode != 0) {
        return {
          'image': 'images/fail-res.png',
          'label': 'proposeFail'.tr,
          'color': CustomColor.red
        };
      } else {
        if (mes.status == MultiMessageStatus.pending) {
          return {
            'image': 'images/pending-res.png',
            'label': 'approvePending'.tr,
            'color': Color(0xffE8CC5C)
          };
        } else {
          return {
            'image': 'images/suc.png',
            'label': 'proposeSucc'.tr,
            'color': CustomColor.primary
          };
        }
      }
    }
  }

  bool get successful {
    return mes.exitCode == 0 || mes.exitCode == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(width: 53, image: AssetImage(data['image'] as String)),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: CommonText(
            data['label'] as String,
            color: data['color'] as Color,
            size: 15,
            weight: FontWeight.w500,
          ),
          padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
        ),
        CommonText.grey(formatTimeByStr(mes.blockTime))
      ],
    );
  }
}

class MultiMessageRow extends StatelessWidget {
  final String label;
  final Widget append;
  final String value;
  MultiMessageRow({this.label = '', this.append, this.value = ''});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              child: CommonText.grey(label),
            ),
            Expanded(child: append ?? BoldText(value))
          ],
        ));
  }
}

class ApproveStatus extends StatelessWidget {
  final String address;
  final String fee;
  final num time;
  final bool ok;
  final int pending;
  final cid;
  ApproveStatus(
      {this.address = '',
      this.fee = '0',
      this.time = 0,
      this.ok,
      this.cid,
      this.pending = 0});
  Widget get statusWidget {
    if (pending == 1) {
      return Image(
        width: 20,
        image: AssetImage("images/clock.png"),
      );
    } else if (ok) {
      return Icon(
        Icons.check_circle_outline,
        color: CustomColor.primary,
        size: 20,
      );
    } else {
      return Icon(Icons.cancel_outlined, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BoldText(dotString(str: address, headLen: 8, tailLen: 8),
                color: address == $store.addr
                    ? CustomColor.primary
                    : Colors.black),
            Spacer(),
            statusWidget,
          ],
        ),
        SizedBox(
          height: 7,
        ),
        BoldText('${"fee".tr}: ${formatFil(fee)}'),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BoldText(formatTimeByStr(time)),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Icon(Icons.more_horiz),
              ),
              onTap: () {
                var url =
                    "$filscanWeb/tipset/message-detail?cid=$cid&utm_source=filwallet_app";
                goWebviewPage(url: url, title: 'detail'.tr);
              },
            )
          ],
        ),
      ],
    );
  }
}

class MultiParams extends StatelessWidget {
  final CacheMultiMessage msg;
  String get methodName => msg.method;
  Widget get proposeType => MultiMessageRow(
        label: 'proposalType'.tr,
        value: msg.method.tr,
      );
  Widget get withdrawWidget {
    if (methodName == FilecoinMethod.withdraw) {
      var amount = msg.decodeInnerParams['AmountRequested'];
      return Column(
        children: [
          CommonCard(Column(
            children: [
              proposeType,
              MultiMessageRow(
                label: 'minerAddr'.tr,
                value: msg.decodeParams['To'] as String,
              ),
              MultiMessageRow(
                label: 'withdrawNum'.tr,
                value: formatFil(amount as String),
              )
            ],
          )),
          SizedBox(
            height: 7,
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget get amountWidget {
    var amount = msg.decodeParams['Value'];
    if (methodName == FilecoinMethod.send) {
      return Column(
        children: [
          CommonCard(Column(
            children: [
              proposeType,
              MultiMessageRow(
                label: 'to'.tr,
                value: msg.decodeParams['To'] as String,
              ),
              MultiMessageRow(
                label: 'amount'.tr,
                value: formatFil(amount as String, returnRaw: true),
              )
            ],
          )),
          SizedBox(
            height: 7,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget get changeOwnerWidget {
    if (methodName == FilecoinMethod.changeOwner) {
      return Column(
        children: [
          CommonCard(Column(
            children: [
              proposeType,
              MultiMessageRow(
                label: 'minerAddr'.tr,
                value: msg.decodeParams['To'] as String,
              ),
              MultiMessageRow(
                  label: 'newOwner'.tr, value: msg.decodeInnerParams as String),
              // MultiMessageRow(
              //   label: 'oldOwner'.tr,
              //   value: msg.to,
              // ),
            ],
          )),
          SizedBox(
            height: 7,
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget get changeWorkerParam {
    var args = msg.decodeInnerParams;
    if (methodName == FilecoinMethod.changeWorker && args is Map) {
      var newWorker = args['NewWorker'];
      var NewControlAddrs = args['NewControlAddrs'] as List<dynamic>;
      List conaddrs = NewControlAddrs is List ? NewControlAddrs : [];
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: msg.decodeParams['To'] as String,
              ),
              MessageRow(
                label: 'worker'.tr,
                value: newWorker.toString(),
              ),
              MessageRow(
                label: 'controller'.tr,
                append: Column(
                  children: List.generate(conaddrs.length, (index) {
                    var addr = conaddrs[index];
                    return Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: CommonText(
                            addr.toString(),
                            weight: FontWeight.w500,
                            align: TextAlign.end,
                          ))
                        ],
                      ),
                      padding: EdgeInsets.only(bottom: 7),
                    );
                  }),
                ),
              ),
            ],
          )),
          SizedBox(
            height: 7,
          )
        ],
      );
    } else {
      return Container();
    }
  }

  MultiParams(this.msg);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        withdrawWidget,
        changeOwnerWidget,
        amountWidget,
        changeWorkerParam
      ],
    );
  }
}
