import 'package:fil/common/global.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/button.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// run mode set
/// page of wallet mode
class WalletModePage extends StatelessWidget {
  void setMode(bool mode) {
    Global.onlineMode = mode;
    Global.store.setBool('runMode', mode);
    Get.toNamed(initWalletPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          child: ImageAl,
                          onTap: () {
                            Get.back();
                          },
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),
                  ImageFil,
                  SizedBox(
                    height: 12,
                  ),
                  CommonText(
                    'FiveToken Pro',
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.w800,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 85, 0, 13),
                    child: CommonText(
                      'selectPurpose'.tr,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  TapCard(
                    items: [
                      CardItem(
                          label: 'onlineMode'.tr,
                          onTap: () {
                            setMode(true);
                          })
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapCard(
                    items: [
                      CardItem(
                          label: 'offlineMode'.tr,
                          onTap: () {
                            setMode(false);
                          })
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            DocButton(
              page: initModePage,
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            CommonText(
              Global.version,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
