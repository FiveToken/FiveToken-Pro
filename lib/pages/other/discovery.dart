import 'package:fil/index.dart';

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
            TabCard(
              items: [CardItem(label: 'mesMake'.tr,onTap: (){
                Get.toNamed(mesMakePage);
              },)],
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
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
