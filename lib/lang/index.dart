import 'package:fil/lang/en.dart';
import 'package:fil/lang/zh.dart';
import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {'en': EN_LANG, 'zh': ZH_LANG,};
}
