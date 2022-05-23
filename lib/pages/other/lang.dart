import 'package:fil/common/global.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// language set page
class LangPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LangPageState();
  }
}

/// page of language
class LangPageState extends State<LangPage> {
  void selectLang(String lang) async {
    Locale locale = Locale(lang);
    Global.store.setString(StoreKeyLanguage, lang);
    Get.updateLocale(locale);
    Global.langCode = lang;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'lang'.tr,
      hasFooter: false,
      grey: true,
      body: Padding(
        child: Column(
          children: [
            TapCard(
              items: [
                CardItem(
                  label: 'English',
                  onTap: () {
                    selectLang('en');
                  },
                ),
                CardItem(
                  label: '中文',
                  onTap: () {
                    selectLang('zh');
                  },
                ),
              ],
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
