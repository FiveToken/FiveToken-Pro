import 'package:fil/common/global.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// create or import different wallet
/// page of crate entrance
class CreateEntrancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isOnline = Global.onlineMode;
    return CommonScaffold(
        hasFooter: false,
        title: 'create'.tr,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                'generalWallet'.tr,
                size: 14,
              ),
              SizedBox(
                height: 12,
              ),
              TapCard(
                items: [
                  CardItem(
                      label: 'createWallet'.tr,
                      onTap: () {
                        Get.toNamed(createWarnPage);
                      })
                ],
              ),
              SizedBox(
                height: 12,
              ),
              TapCard(
                items: [
                  CardItem(
                      label: 'pkImport'.tr,
                      onTap: () {
                        Get.toNamed(importPrivateKeyPage);
                      }),
                  CardItem(
                      label: 'mneImport'.tr,
                      onTap: () {
                        Get.toNamed(importMnePage);
                      })
                ],
              ),
              Visibility(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
                      child: CommonText(
                        'readonlyWallet'.tr,
                        size: 14,
                      ),
                    ),
                    TapCard(
                      items: [
                        CardItem(
                            label: 'importReadonly'.tr,
                            onTap: () {
                              Get.toNamed(readonlyPage);
                            })
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
                      child: CommonText(
                        'minerWallet'.tr,
                        size: 14,
                      ),
                    ),
                    TapCard(
                      items: [
                        CardItem(
                            label: 'importMiner'.tr,
                            onTap: () {
                              Get.toNamed(minerPage);
                            })
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
                visible: isOnline,
              )
            ],
          ),
        ));
  }
}
