import 'package:fil/index.dart';
import 'package:fil/pages/other/webview.dart';

/// display infomation of the proposal or approval
class MultiProposalDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiProposalDetailPageState();
  }
}

class MultiProposalDetailPageState extends State<MultiProposalDetailPage> {
  CacheMultiMessage msg;
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
        Global.provider
            .getNonceAndGas(to: wallet.id, method: 3, methodName: 'Approve');
      }
    }
  }

  Future<TMessage> genMsg() async {
    var ctrl = $store;
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
    var message = TMessage(
        version: 0,
        method: 3,
        nonce: $store.nonce,
        from: $store.wal.addr,
        to: wallet.id,
        params: decodeParams['param'],
        value: '0',
        gasFeeCap: ctrl.gas.value.feeCap,
        gasLimit: ctrl.gas.value.gasLimit,
        gasPremium: ctrl.gas.value.premium);
    return message;
  }

  void pushMessage(String pass, {bool increaseNonce}) async {
    var message = await genMsg();
    var wal = $store.wal;
    var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
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
                    nonce: message.nonce,
                    time: getSecondSinceEpoch()));
            Get.back();
            // Get.offNamedUntil(
            //     multiMainPage, (route) => route.settings.name == mainPage);
          });
    } catch (e) {
      print(e);
      showCustomError(getErrorMessage(e.toString()));
    }
  }

  Future getActor(String addr) async {
    try {
      var id = await Global.provider.getActorId(addr);
      actorId = id;
    } catch (e) {
      print(e);
    }
  }

  void hanldeConfirm() async {
    if (proposer.substring(1) == $store.wal.addr.substring(1)) {
      showCustomError('sameAsSigner'.tr);
      return;
    }
    if (!$store.canPush) {
      var valid =
          await Global.provider.getNonceAndGas(to: wallet.id, method: 3);
      if (!valid) {
        showCustomError('errorSetGas'.tr);
        return;
      }
    }
    var balanceNum = BigInt.tryParse($store.wal.balance);
    var feeNum = $store.gas.value.feeNum;
    if (balanceNum < feeNum) {
      showCustomError('errorLowBalance'.tr);
      return;
    }
    if (actorId == '') {
      if (!wallet.signerMap.containsKey(proposer)) {
        showCustomError('getActorFailed'.tr);
        return;
      } else {
        actorId = wallet.signerMap[proposer];
      }
    }
    if ($store.wal.readonly == 1) {
      var msg = await genMsg();
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
              var private =
                  await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
              try {
                await Global.provider.speedup(
                    private: private,
                    gas: $store.chainGas,
                    methodName: FilecoinMethod.approve);
                Get.back();
              } catch (e) {
                showCustomError(e.toString());
              }
            });
          });
    }
  }

  String get methodName => msg.method;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'detail'.tr,
      hasFooter: needApprove,
      onPressed: () {
        hanldeConfirm();
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
                      Visibility(
                        child: Obx(() => SetGas(
                              maxFee: $store.maxFee,
                              gas: $store.chainGas,
                            )),
                        visible: needApprove,
                      )
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
        Image(width: 53, image: AssetImage(data['image'])),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: CommonText(
            data['label'],
            color: data['color'],
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
                value: msg.decodeParams['To'],
              ),
              MultiMessageRow(
                label: 'withdrawNum'.tr,
                value: formatFil(amount),
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
                value: msg.decodeParams['To'],
              ),
              MultiMessageRow(
                label: 'amount'.tr,
                value: formatFil(amount, returnRaw: true),
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
                value: msg.decodeParams['To'],
              ),
              MultiMessageRow(
                  label: 'newOwner'.tr, value: msg.decodeInnerParams),
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
      List conaddrs =
          args['NewControlAddrs'] is List ? args['NewControlAddrs'] : [];

      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: msg.decodeParams['To'],
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
