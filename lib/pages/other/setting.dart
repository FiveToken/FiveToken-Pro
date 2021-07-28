import 'package:fil/index.dart';

class SetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetPageState();
  }
}

class SetPageState extends State<SetPage> {
  String get lang {
    return Global.langCode == 'zh' ? 'cn' : 'en';
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'set'.tr,
      hasFooter: false,
      grey: true,
      body: Padding(
        child: Column(
          children: [
            TabCard(
              items: [
                CardItem(
                  label: 'addrBook'.tr,
                  onTap: () {
                    Get.toNamed('/addressBook/index');
                  },
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
              items: [
                CardItem(
                  label: 'lang'.tr,
                  onTap: () {
                    Get.toNamed(langPage);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            // TabCard(
            //   items: [
            //     CardItem(
            //       label: 'notification'.tr,
            //       onTap: () {
            //         Get.toNamed(notificationPage);
            //       },
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 15,
            // ),
            TabCard(
              items: [
                CardItem(
                  label: 'about'.tr,
                  onTap: () {
                    Get.toNamed(aboutPage);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
              items: [
                CardItem(
                  label: 'service'.tr,
                  onTap: () {
                    var url = 'https://fivetoken.io/private?lang=$lang';
                    openInBrowser(url);
                  },
                ),
                CardItem(
                  label: 'clause'.tr,
                  onTap: () {
                    var url = 'https://fivetoken.io/service?lang=$lang';
                    openInBrowser(url);
                  },
                ),
                CardItem(
                  label: 'version'.tr,
                  append: CommonText(
                    Global.version,
                    color: CustomColor.grey,
                  ),
                )
              ],
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
