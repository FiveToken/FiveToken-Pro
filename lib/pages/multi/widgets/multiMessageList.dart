
import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
class MultiMessageItem extends StatelessWidget {
  final StoreMultiMessage mes;
  MultiMessageItem(this.mes);
  bool get isSend {
    return mes.from == $store.wal.address;
  }

  bool get fail {
    return mes.exitCode != 0;
  }

  bool get pending {
    return mes.pending == 1;
  }

  String get addr {
    return '${'to'.tr} ${dotString(str: mes.msigTo ?? '')}';
  }

  String get value {
    var v = atto2Fil(mes.msigValue);
    return '${mes.msigValue != null ? v : '0'}' + ' FIL';
  }

  bool get isApproval {
    return mes.methodName == 'Approve' || mes.type == 'approval';
  }

  Color get color {
    int n;
    if (pending) {
      n = 0xffE8CC5C;
    } else if (fail) {
      n = 0xffB4B5B7;
    } else {
      if (isApproval) {
        n = 0xff5C8BCB;
      } else {
        n = 0xff5CC1CB;
      }
    }
    return Color(n);
  }

  String get path {
    if (pending) {
      return 'pending.png';
    } else if (fail) {
      return 'fail.png';
    } else {
      if (isApproval) {
        return 'approval.png';
      } else {
        return 'proposal.png';
      }
    }
  }

  String get label {
    //String prefix = 'Approve';
    if (isApproval) {
      if (pending) {
        return 'approvalPending'.tr;
      } else {
        if (mes.exitCode != 0) {
          return 'approvalFail'.tr;
        } else {
          return 'approvalSucc'.tr;
        }
      }
    } else {
      //prefix = 'Propose';
      if (pending) {
        return 'proposalPending'.tr;
      } else {
        if (mes.exitCode != 0) {
          return 'proposalFail'.tr;
        } else {
          if (mes.msigApproved != mes.msigRequired) {
            return 'waitApprove'.tr;
          } else {
            return 'proposalSucc'.tr;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        var needApprove = mes.msigApproved != mes.msigRequired &&
            mes.from != $store.wal.addrWithNet;
        Get.toNamed(multiProposalDetailPage, arguments: {
          'msg': mes,
          'needApprove': needApprove,
          'type': mes.type,
          'label': label
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            IconBtn(
              size: 32,
              color: color,
              path: path,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Layout.colStart([
                CommonText.main(
                  label,
                  size: 15,
                ),
                CommonText.grey(addr, size: 10),
              ]),
            ),
            CommonText(
              value,
              size: 15,
              color: CustomColor.primary,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}

