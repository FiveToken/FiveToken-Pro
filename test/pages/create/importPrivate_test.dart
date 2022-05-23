import 'package:fil/pages/create/importPrivateKey.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import '../../box.dart';
import '../../constant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MethodChannel c = MethodChannel('flotus');
  c.setMockMethodCallHandler((methodCall) async {
    switch (methodCall.method) {
      case 'secpPrivateToPublic':
        return FilAddr;
      case 'genAddress':
        return FilAddr;
    }
  });
  var box = mockWalletbox();
  when(box.containsKey(any)).thenReturn(false);
  testWidgets('test render import private page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: importPrivateKeyPage,
      getPages: [
        GetPage(name: importPrivateKeyPage, page: () => ImportPrivateKeyPage()),
        GetPage(name: passwordSetPage, page: () => PassInitPage())
      ],
    )));
    await tester.enterText(find.byType(TextField).first, FilHexPrivate);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(Get.currentRoute, passwordSetPage);
  });
}
