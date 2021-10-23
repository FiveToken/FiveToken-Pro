import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';

class MultiMessageItem extends StatelessWidget {
  final CacheMultiMessage mes;
  final int threshold;
  MultiMessageItem({@required this.mes, @required this.threshold});
  bool get fail {
    return mes.exitCode != 0;
  }

  bool get isPropose => mes.type == 0;
  bool get pending {
    return mes.pending == 1;
  }

  int get approveNum {
    var n = mes.approves.where((m) => m.exitCode == 0).toList().length;
    return n + 1;
  }

  String get addr {
    var str =
        isReceive ? mes.from : (isPropose ? mes.decodeParams['To'] : mes.to);
    return '${isPropose ? 'to'.tr : 'from'.tr}: ${dotString(str: str)}';
  }

  bool get complete => mes.status == MultiMessageStatus.applied;
  bool get isReceive => mes.type == 1;
  Widget get progress {
    return complete
        ? Container(
            width: threshold * 15.0,
            height: 6,
            color: Color(0xff67C23A),
          )
        : Container(
            height: 6,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color(0xffcccccc))),
            child: Row(
              children: List.generate(threshold, (index) {
                return Container(
                  width: 15,
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              color: Color(0xffcccccc),
                              width: index == threshold - 1 ? 0 : 1)),
                      color: index < approveNum
                          ? Color(0xff67C23A)
                          : Colors.white),
                );
              }),
            ),
          );
  }

  String get value {
    if (!isPropose) {
      return formatFil(mes.value, returnRaw: true);
    }
    try {
      var value = '0';
      if (mes.method == FilecoinMethod.send) {
        value = mes.decodeParams['Value'];
      }
      if (mes.method == FilecoinMethod.withdraw) {
        var innerParams = jsonDecode(mes.innerParams);
        if (innerParams is Map) {
          value = innerParams['AmountRequested'];
        }
      }
      var v = formatFil(value, returnRaw: true);
      return v;
    } catch (e) {
      return '0 FIL';
    }
  }

  List<MultiApproveMessage> get pendingApproves {
    return OpenedBox.multiApproveInstance.values
        .where((m) => m.proposeCid == mes.cid && m.from == $store.addr)
        .toList();
  }

  List<MultiApproveMessage> get completeApproves {
    return mes.approves ?? [];
  }

  Widget get statusWidget {
    var getText = (Color color, String text) {
      return Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
          SizedBox(
            width: 5,
          ),
          CommonText(
            text,
            size: 12,
          )
        ],
      );
    };
    if (isReceive) {
      return Container();
    }
    if (pending) {
      return Image(
        width: 20,
        image: AssetImage("images/clock.png"),
      );
    } else if (fail) {
      return Image(
        width: 20,
        image: AssetImage("images/close-r.png"),
      );
    } else {
      if (complete) {
        return Container();
      }
      if (mes.from == $store.addr) {
        return Container();
      } else {
        if (pendingApproves.isNotEmpty ||
            completeApproves.where((m) => m.from == $store.addr).isEmpty) {
          return getText(CustomColor.brown, 'waitApprove'.tr);
        } else if (completeApproves
            .where((m) => m.from == $store.addr && m.exitCode != 0)
            .isNotEmpty) {
          return getText(CustomColor.red, 'approveFail'.tr);
        } else {
          return getText(CustomColor.green, 'approveSucc'.tr);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPropose) {
          Get.toNamed(multiProposalDetailPage, arguments: {'msg': mes});
        } else {
          Get.toNamed(filDetailPage,
              arguments: StoreMessage(
                  from: mes.from,
                  to: mes.to,
                  blockTime: mes.blockTime,
                  signedCid: mes.cid,
                  nonce: mes.nonce,
                  multiMethod: 'approve',
                  value: mes.value,
                  pending: 0));
        }
      },
      child: Stack(
        children: [
          Positioned(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                isPropose
                    ? IconBtn(
                        size: 32,
                        color: Color(0xff5CC1CB),
                        path: ('proposal.png'),
                      )
                    : IconBtn(
                        size: 32,
                        color: Color(0xff5CC1CB),
                        path: ('send.png'),
                      ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      children: [
                        CommonText.main(
                          isPropose ? mes.method.tr : 'receive'.tr,
                          size: 15,
                        ),
                        Spacer(),
                        CommonText(
                          value,
                          size: 15,
                          color: CustomColor.primary,
                          weight: FontWeight.w500,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        CommonText.grey(addr, size: 10),
                        Spacer(),
                        isReceive || pending || fail ? Container() : progress,
                      ],
                    )
                  ],
                )),
              ],
            ),
          )),
          Positioned(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                ),
                statusWidget
              ],
            ),
            // left: Get.width / 2,
            top: 15,
          )
        ],
      ),
    );
  }
}
