import 'dart:convert';
import 'package:fil/bloc/detail/detail_bloc.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/time.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// display detail of a transaction
class FilDetailPage extends StatefulWidget {
  @override
  State createState() => FilDetailPageState();
}

/// page of transfer detail
class FilDetailPageState extends State<FilDetailPage> {
  StoreMessage mes = Get.arguments as StoreMessage;
  @override
  void initState() {
    super.initState();
  }

  void goFilScan(String cid) {
    var url =
        "$filscanWeb/tipset/message-detail?cid=${cid}&utm_source=filwallet_app";
    goWebviewPage(url: url, title: 'detail'.tr);
  }

  Widget withdrawWidget(context, state) {
    if (state.methodName == FilecoinMethod.withdraw) {
      String amount = state.args['AmountRequested'] as String;
      String to = state.to as String;
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: to,
              ),
              MessageRow(
                label: 'withdrawNum'.tr,
                value: formatFil(amount, returnRaw: true),
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

  Widget changeOwnerWidget(context, state) {
    if (state.methodName == FilecoinMethod.changeOwner) {
      String to = state.to as String;
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: to,
              ),
              MessageRow(
                label: 'newOwner'.tr,
                value: state.args.toString(),
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

  Widget createminerWalletidget(context, state) {
    if (state.methodName == FilecoinMethod.createMiner &&
        state.args is Map &&
        state.returns is Map) {
      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: state.returns['IDAddress'] as String,
              ),
              MessageRow(
                label: 'owner'.tr,
                value: state.args['Owner'] as String,
              ),
              MessageRow(
                label: 'worker'.tr,
                value: state.args['Worker'] as String,
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

  Widget execWidget(context, state) {
    var miner = '';
    if (state.methodName == FilecoinMethod.exec &&
        state.returns is Map &&
        state.returns['IDAddress'] != null) {
      miner = state.returns['IDAddress'] as String;
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

  Widget amountWidget(context, state) {
    String amount = state.value as String;
    if (state.methodName == FilecoinMethod.send) {
      return Column(
        children: [
          CommonCard(MessageRow(
            label: 'amount'.tr,
            value: formatFil(amount, returnRaw: true),
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

  Widget changeWorkerParam(context, state) {
    var args = state.args;
    String to = state.to as String;
    if (state.methodName == FilecoinMethod.changeWorker && args is Map) {
      var newWorker = args['NewWorker'];
      var newControllerAddress = args['NewControlAddrs'] as List<dynamic>;
      List conaddrs = newControllerAddress is List ? newControllerAddress : [];

      return Column(
        children: [
          CommonCard(Column(
            children: [
              MessageRow(
                label: 'minerAddr'.tr,
                value: to,
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
    return BlocProvider(
        create: (context) => DetailBloc()..add(getMessageDetailEvent(mes)),
        child: BlocBuilder<DetailBloc, DetailState>(builder: (context, state) {
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
                          createminerWalletidget(context, state),
                          withdrawWidget(context, state),
                          amountWidget(context, state),
                          changeWorkerParam(context, state),
                          execWidget(context, state),
                          changeOwnerWidget(context, state),
                        ],
                      ),
                      visible: state.pending == 0),
                  Visibility(
                      visible: state.pending != 1,
                      child: CommonCard(MessageRow(
                        label: 'fee'.tr,
                        value: formatFil(
                            BigInt.parse(state.allGasFee).toString(),
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
                          value: state.from,
                        ),
                        MessageRow(
                          label: 'to'.tr,
                          selectable: true,
                          value: state.to,
                        ),
                        MessageRow(
                          label: 'Nonce',
                          value: state.nonce.toString(),
                        ),
                      ],
                    )),
                    visible: state.methodName != FilecoinMethod.changeOwner,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  mes.pending != 1
                      ? ChainMeta(
                          cid: state.signedCid,
                          height: state.height == null
                              ? ''
                              : state.height.toString(),
                          params: null)
                      : CommonCard(MessageRow(
                          label: 'cid'.tr,
                          selectable: true,
                          value: state.signedCid,
                        )),
                ],
              ),
            ),
          );
        }));
  }
}

/// widget of message status
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

/// widget of chain meta
class ChainMeta extends StatelessWidget {
  final String cid;
  final String height;
  final dynamic params;
  void goFilScan(cid) {
    var url =
        "$filscanWeb/tipset/message-detail?cid=$cid&utm_source=filwallet_app";
    goWebviewPage(url: url, title: 'detail'.tr);
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
            goFilScan(cid);
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
