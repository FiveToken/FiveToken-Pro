import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// make or push message
/// page of discovery
class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'discovery'.tr,
      hasFooter: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          children: [
            TapCard(
              items: [
                CardItem(
                  label: 'mesMake'.tr,
                  onTap: () {
                    Get.toNamed(mesMakePage);
                  },
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TapCard(
              items: [
                CardItem(
                  label: 'mesPush'.tr,
                  onTap: () {
                    Get.toNamed(mesPushPage);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
