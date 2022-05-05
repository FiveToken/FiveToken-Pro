import 'package:fil/common/global.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/init/mode.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import '../../widgets/dialog_test.dart';

void main() {
  testWidgets('test render init  page', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      when(store.setString(any, any))
          .thenAnswer((realInvocation) async => true);
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: initLangPage,
        getPages: [
          GetPage(page: () => SelectLangPage(), name: initLangPage),
          GetPage(page: () => WalletInitPage(), name: initWalletPage),
          GetPage(page: () => WalletModePage(), name: initModePage),
        ],
      ));
      expect(find.byType(TapCard), findsNWidgets(2));
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, initModePage);
      expect(find.byType(TapCard), findsNWidgets(2));
      await tester.tap(find.text('onlineMode'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, initWalletPage);
    });
  });
}
