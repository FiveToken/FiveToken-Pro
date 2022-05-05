import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/address/main.dart';
import 'package:fil/pages/other/about.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/setting.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../widgets/dialog_test.dart';

void main() {
  Get.put(StoreController());
  Global.store = MockSharedPreferences();
  var box = mockAddressBoxbox();
  when(box.values).thenReturn([Wallet()]);
  testWidgets('test render setting and lang page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: setPage,
      getPages: [
        GetPage(name: langPage, page: () => LangPage()),
        GetPage(name: setPage, page: () => SetPage()),
        GetPage(name: aboutPage, page: () => AboutPage()),
        GetPage(name: addressIndexPage, page: ()=> AddressBookIndexPage())
      ],
    ));
    expect(find.byType(TapCard), findsNWidgets(5));
    await tester.tap(find.text('lang'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(CardItem), findsNWidgets(2));

    Get.toNamed(setPage);
    expect(Get.currentRoute, setPage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('about'.tr));


    Get.toNamed(setPage);
    expect(Get.currentRoute, setPage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('addrBook'.tr));

    // Get.toNamed(setPage);
    // expect(Get.currentRoute, setPage);
    // await tester.pumpAndSettle();
    // await tester.tap(find.text('service'.tr));
    //
    // Get.toNamed(setPage);
    // expect(Get.currentRoute, setPage);
    // await tester.pumpAndSettle();
    // await tester.tap(find.text('clause'.tr));

    Get.toNamed(setPage);
    expect(Get.currentRoute, setPage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('latestVersion'.tr));

  });
}
