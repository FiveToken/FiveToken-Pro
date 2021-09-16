import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

/// display detail of a transaction
class FilDetailPage extends StatefulWidget {
  @override
  State createState() => FilDetailPageState();
}

class FilDetailPageState extends State<FilDetailPage> {
  MessageDetail msgDetail =
      MessageDetail(value: '0', methodName: '', allGasFee: '0');
  StoreMessage mes = Get.arguments;
  StoreController controller = Get.find();
  String amount;
  void getMessageDetailInfo() async {
    if (mes.pending == 1 || mes.exitCode == -1 || mes.exitCode == -2) {
      setState(() {
        msgDetail = MessageDetail(
            from: mes.from,
            to: mes.to,
            value: mes.value,
            methodName: '',
            signedCid: mes.signedCid);
        amount = mes.value;
      });
      return;
    }
    showCustomLoading('Loading');
    var res = await getMessageDetail(mes);
    dismissAllToast();
    if (res.height != null) {
      setState(() {
        msgDetail = res;
        if (res.methodName == FilecoinMethod.withdraw && res.args is Map) {
          amount = res.args['AmountRequested'];
        }
      });
    }
  }

  String get methodName => msgDetail.methodName;
  String get toLabel {
    if ([
      FilecoinMethod.withdraw,
      FilecoinMethod.changeWorker,
      FilecoinMethod.changeOwner
    ].contains(methodName)) {
      return 'minerAddr'.tr;
    } else {
      return 'to'.tr;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) => getMessageDetailInfo());
  }

  void goFilScan(MessageDetail m) {
    openInBrowser(
        "$filscanWeb/tipset/message-detail?cid=${m.signedCid}&utm_source=filwallet_app");
  }

  Widget get withdrawWidget {
    if (methodName == FilecoinMethod.withdraw) {
      amount = msgDetail.args['AmountRequested'];
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: msgDetail.to,
              ),
              MessageRow(
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

  Widget get changeOwnerWidget {
    if (methodName == FilecoinMethod.changeOwner) {
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: msgDetail.to,
              ),
              MessageRow(
                label: 'newOwner'.tr,
                value: msgDetail.args.toString(),
              ),
              MessageRow(
                label: 'oldOwner'.tr,
                value: msgDetail.from.toString(),
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

  Widget get createMinerWidget {
    if (msgDetail.methodName == FilecoinMethod.createMiner &&
        msgDetail.args is Map &&
        msgDetail.returns is Map) {
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: msgDetail.returns['IDAddress'],
              ),
              MessageRow(
                label: 'owner'.tr,
                value: msgDetail.args['Owner'],
              ),
              MessageRow(
                label: 'worker'.tr,
                value: msgDetail.args['Worker'],
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

  Widget get execWidget {
    var miner = '';
    if (methodName == FilecoinMethod.exec && msgDetail.returns is Map) {
      miner = msgDetail.returns['IDAddress'];
      return Column(
        children: [
          CommonCard(MessageRow(
            label: 'multisig'.tr,
            value: miner,
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

  Widget get amountWidget {
    var amount = msgDetail.value;
    if (methodName == FilecoinMethod.transfer) {
      return Column(
        children: [
          CommonCard(MessageRow(
            label: 'amount'.tr,
            value: formatFil(amount),
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

  Widget get changeWorkerParam {
    var args = msgDetail.args;
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
                value: msgDetail.to,
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

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'detail'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(12, 30, 12, 40),
        child: Column(
          children: [
            Container(
              child: MessageStatusHeader(mes),
              width: double.infinity,
            ),
            SizedBox(
              height: 25,
            ),
            Visibility(
                child: Column(
                  children: [
                    createMinerWidget,
                    withdrawWidget,
                    amountWidget,
                    changeWorkerParam,
                    execWidget,
                    changeOwnerWidget,
                  ],
                ),
                visible: mes.pending == 0),
            Visibility(
                visible: mes.pending != 1,
                child: CommonCard(MessageRow(
                  label: 'fee'.tr,
                  value: formatFil(BigInt.parse(msgDetail.allGasFee).toString(),
                      size: 5),
                ))),
            SizedBox(
              height: 7,
            ),
            Visibility(
                child: CommonCard(Column(
              children: [
                MessageRow(
                  label: 'from'.tr,
                  selectable: true,
                  value: msgDetail.from,
                ),
                MessageRow(
                  label: 'to'.tr,
                  selectable: true,
                  value: msgDetail.to,
                )
              ],
            )),visible: methodName!=FilecoinMethod.changeOwner,),
            SizedBox(
              height: 7,
            ),
            mes.pending != 1
                ? ChainMeta(
                    cid: msgDetail.signedCid,
                    height: msgDetail.height == null
                        ? ''
                        : msgDetail.height.toString(),
                    params: null)
                : CommonCard(MessageRow(
                    label: 'cid'.tr,
                    selectable: true,
                    value: msgDetail.signedCid,
                  )),
          ],
        ),
      ),
    );
  }
}

class MessageStatusHeader extends StatelessWidget {
  final StoreMessage mes;
  MessageStatusHeader(this.mes);
  bool get pending {
    return mes.pending == 1;
  }

  bool get successful {
    return mes.exitCode == 0 || mes.exitCode == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
            width: 53,
            image: AssetImage(pending
                ? 'images/pending-res.png'
                : (successful ? 'images/suc.png' : 'images/fail-res.png'))),
        Container(
          child: CommonText(
            pending
                ? 'pending'.tr
                : (successful ? 'tradeSucc'.tr : 'tradeFail'.tr),
            color: pending
                ? Color(0xffE8CC5C)
                : (successful ? CustomColor.primary : CustomColor.red),
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

/// widget to show message field
class MessageRow extends StatelessWidget {
  final bool selectable;
  final String label;
  final String value;
  final Widget append;
  final TextAlign align;
  MessageRow(
      {this.label,
      this.value,
      this.append,
      this.selectable = false,
      this.align});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.grey(label),
            SizedBox(
              width: 52,
            ),
            Expanded(
                child: append ??
                    GestureDetector(
                      onTap: () {
                        if (selectable) {
                          copyText(value);
                          showCustomToast('copySucc'.tr);
                        }
                      },
                      child: Text(
                        value,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        textAlign: this.align ?? TextAlign.end,
                      ),
                    ))
          ],
        ));
  }
}

class ChainMeta extends StatelessWidget {
  final String cid;
  final String height;
  final dynamic params;
  void goFilScan() {
    openInBrowser(
        "$filscanWeb/tipset/message-detail?cid=$cid&utm_source=filwallet_app");
  }

  ChainMeta({this.cid, this.height, this.params});
  bool get showParams {
    return params != null && params is Map;
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(Column(
      children: [
        MessageRow(
          label: 'cid'.tr,
          selectable: true,
          value: cid,
        ),
        MessageRow(
          label: 'height'.tr,
          value: height,
        ),
        Visibility(
            visible: showParams,
            child: MessageRow(
              label: 'params'.tr,
              align: TextAlign.left,
              value: JsonEncoder.withIndent(" ").convert(params),
            )),
        GestureDetector(
          onTap: () {
            goFilScan();
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: 48,
            child: CommonText(
              'more'.tr,
              size: 14,
              weight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
          ),
        )
      ],
    ));
  }
}
