import 'package:fil/index.dart';
/// make or push message
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
              items: [CardItem(label: 'mesMake'.tr,onTap: (){
                Get.toNamed(mesMakePage);
              },)],
            ),
            SizedBox(
              height: 15,
            ),
            TapCard(
              items: [CardItem(label: 'mesPush'.tr,onTap: (){
                Get.toNamed(mesPushPage);
              },)],
            ),
          ],
        ),
      ),
    );
  }
}
