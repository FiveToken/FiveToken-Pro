import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

/// display infomation of the proposal or approval
class MultiProposalDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiProposalDetailPageState();
  }
}

class MultiProposalDetailPageState extends State<MultiProposalDetailPage> {
  StoreMultiMessage msg;
  bool needApprove = false;
  String type = 'proposal';
  MessageDetail detail;
  String label = '';
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      msg = Get.arguments['msg'] as StoreMultiMessage;
      needApprove = (Get.arguments['needApprove'] as bool) ?? false;
      type = Get.arguments['type'] as String;
      label = Get.arguments['label'] as String;
      if (msg.pending == 0) {
        Future.delayed(Duration.zero).then((value) {
          getDetail(msg.signedCid);
        });
      }
    }
  }

  void getDetail(String cid) async {
    showCustomLoading('Loading');
    var detail = await getMessageDetail(StoreMessage(signedCid: cid));
    dismissAllToast();
    setState(() {
      this.detail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    var complete = msg.pending == 0 && detail != null;
    return CommonScaffold(
      title: type == 'proposal' ? 'proposalDetail'.tr : 'approvalDetail'.tr,
      hasFooter: needApprove,
      onPressed: () {
        Get.toNamed(multiApprovalPage, arguments: {'cid': msg.signedCid});
      },
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      MultiMessageStatusHeader(msg, label),
                      SizedBox(
                        height: 12,
                      ),
                      CommonCard(MessageRow(
                        label: 'amount'.tr,
                        value: atto2Fil(msg.msigValue) + ' FIL',
                      )),
                      SizedBox(
                        height: 7,
                      ),
                      complete
                          ? CommonCard(MessageRow(
                              label: 'fee'.tr,
                              value: formatFil(
                                      BigInt.parse(detail.allGasFee ?? '0')
                                          .toString()) ??
                                  ''))
                          : Container(),
                      SizedBox(
                        height: 7,
                      ),
                      CommonCard(msg.type == 'approval'
                          ? Column(
                              children: [
                                MessageRow(
                                    label: 'approver'.tr, value: msg.from),
                                msg.proposalCid == null
                                    ? Container()
                                    : MessageRow(
                                        label: 'approveId'.tr,
                                        value: msg.proposalCid ?? '',
                                      ),
                                MessageRow(
                                  label: 'receiver'.tr,
                                  value: msg.msigTo,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                MessageRow(
                                    label: 'proposer'.tr, value: msg.from),
                                MessageRow(
                                  label: 'receiveAddr'.tr,
                                  value: msg.msigTo,
                                ),
                              ],
                            )),
                      SizedBox(
                        height: 7,
                      ),
                      complete
                          ? ChainMeta(
                              cid: detail.signedCid,
                              params: detail.args,
                              height: detail.height.toString(),
                            )
                          : CommonCard(MessageRow(
                              label: 'cid'.tr,
                              selectable: true,
                              value: msg.signedCid,
                            )),
                    ],
                  ))),
          SizedBox(
            height: needApprove ? 120 : 0,
          )
        ],
      ),
      footerText: 'approve'.tr,
    );
  }
}

class MultiMessageStatusHeader extends StatelessWidget {
  final StoreMultiMessage mes;
  final String label;
  MultiMessageStatusHeader(this.mes, this.label);
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
          width: double.infinity,
          alignment: Alignment.center,
          child: CommonText(
            label,
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
