import 'package:fil/chain/constant.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'index.dart';

/// widget of message item
class MessageItem extends StatelessWidget {
  final StoreMessage mes;
  MessageItem(this.mes);
  bool get isSend {
    return mes.from == $store.wal.address;
  }

  bool get isWithdraw {
    return mes.methodName == FilecoinMethod.withdraw;
  }

  bool get fail {
    return mes.exitCode != 0;
  }

  bool get pending {
    return mes.pending == 1;
  }

  String get addr {
    var pre = isWithdraw
        ? 'to'.tr
        : isSend
            ? 'to'.tr
            : 'from'.tr;
    var address = isSend ? mes.to : mes.from;
    return '$pre: ${dotString(str: address)}';
  }

  String get value {
    var pre = isSend ? '-' : '+';
    if (isWithdraw) {
      pre = '+';
    }
    if (![FilecoinMethod.withdraw, FilecoinMethod.transfer]
        .contains(mes.methodName)) {
      pre = '';
    }
    return '${pending || fail ? '' : pre}${formatFil(mes.value, returnRaw: true)}';
  }

  Widget get statusWidget {
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
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(filDetailPage, arguments: mes);
      },
      child: Stack(
        children: [
          Positioned(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                IconBtn(
                  size: 32,
                  color: Color(isSend ? 0xff5C8BCB : 0xff5CC1CB),
                  path: (isSend ? 'rec.png' : 'send.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Layout.colStart([
                    CommonText.main(
                      mes.methodName.tr,
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
          )),
          Positioned(
            child: statusWidget,
            left: Get.width / 2,
            top: 25,
          )
        ],
      ),
    );
  }
}
