import 'package:fil/index.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:share/share.dart';

class DrawerBody extends StatelessWidget {
  final Noop onTap;
  DrawerBody({this.onTap});
  @override
  Widget build(BuildContext context) {
    var label = $store.wal.label;
    var addr = $store.wal.addr;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          GestureDetector(
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                ),
                CommonText(
                  label,
                  size: 18,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  width: 10,
                ),
                Image(width: 20, image: AssetImage('images/switch.png'))
              ],
            ),
            onTap: () {
              Get.back();
              onTap();
              //Get.toNamed(walletSelectPage);
            },
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            margin: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
                color: CustomColor.bgGrey,
                borderRadius: BorderRadius.circular(5)),
            child: CommonText(
              dotString(str: addr),
              color: CustomColor.grey,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(thickness: .2),
          DrawerItem(
            onTap: () {
              Get.back();
            },
            label: 'wallet'.tr,
            iconPath: 'wal.png',
          ),
          DrawerItem(
            onTap: () {
              Get.back();
              var url =
                  '$filscanWeb/tipset/address-detail?address=$addr&utm_source=filwallet_app';
              goWebviewPage(title: 'detail'.tr, url: url);
            },
            label: 'filscan'.tr,
            iconPath: 'browser.png',
          ),
          DrawerItem(
            onTap: () {
              Get.toNamed(discoveryPage);
            },
            label: 'discovery'.tr,
            iconPath: 'dis.png',
          ),
          Divider(thickness: .2),
          DrawerItem(
            onTap: () {
              Share.share(addr);
            },
            label: 'shareAddr'.tr,
            iconPath: 'share.png',
          ),
          DrawerItem(
            onTap: () {
              Get.toNamed(setPage);
            },
            label: 'set'.tr,
            iconPath: 'setting.png',
          ),
          DrawerItem(
            onTap: () {
              var url = Global.langCode == 'zh'
                  ? 'https://docs.google.com/forms/d/e/1FAIpQLSeZrn_8u6GUHlQQRZdvwRUrhCNOCiopVe1_z9alvOiyQFJW5A/viewform?usp=sf_link'
                  : 'https://docs.google.com/forms/d/e/1FAIpQLSfXRxdhK8NPcMxrHtDNpocFGZ5sFpINmcurYes-5x2c80aAdQ/viewform?usp=sf_link';
              goWebviewPage(url: url, title: 'feedback'.tr);
            },
            label: 'feedback'.tr,
            iconPath: 'feedback.png',
          ),
          Divider(thickness: .2),
          Spacer(),
          Container(
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                ),
                Image(
                  width: 25,
                  image: AssetImage('images/fivetoken.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                CommonText(
                  'FiveToken',
                  size: 14,
                  weight: FontWeight.w500,
                  color: CustomColor.primary,
                )
              ],
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
      color: Colors.white,
    );
  }
}

class DrawerItem extends StatelessWidget {
  final Noop onTap;
  final String label;
  final String iconPath;
  DrawerItem(
      {@required this.onTap, @required this.label, @required this.iconPath});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.back();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Image(width: 20, image: AssetImage('images/$iconPath')),
            SizedBox(
              width: 25,
            ),
            CommonText(
              label,
              size: 14,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}
