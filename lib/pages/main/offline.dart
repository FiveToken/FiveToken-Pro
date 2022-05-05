import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/pages/main/widgets/service.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// page of offline wallet
class OfflineWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 25,
        ),
        Obx(
          () => CommonText(
            $store.wal.label,
            size: 30,
            weight: FontWeight.w800,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        CopyWalletAddr(),
        SizedBox(
          height: 18,
        ),
        OfflineBtns(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),
        Container(
          child: CommonText.center('notOnline'.tr),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
      ],
    );
  }
}

class CopyWalletAddr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Obx(() => CommonText(
                dotString(str: $store.wal.addr),
                size: 14,
                color: Color(0xffB4B5B7),
              )),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Color(0xfff8f8f8)),
        ),
        SizedBox(
          width: 14,
        ),
        GestureDetector(
          onTap: () {
            copyText($store.wal.addr);
            showCustomToast('copyAddr'.tr);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.circular(5)),
            child: Image(
                fit: BoxFit.fitWidth,
                width: 17,
                height: 17,
                image: AssetImage('images/copy-w.png')),
          ),
        )
      ],
    );
  }
}
