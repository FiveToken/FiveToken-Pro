import 'package:fil/pages/create/importMne.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
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
        return '';
      case 'genAddress':
        return FilAddr;
    }
  });
  var box = mockWalletbox();
  when(box.containsKey(any)).thenReturn(false);
  testWidgets('test render import mne page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: importMnePage,
      getPages: [
        GetPage(name: importMnePage, page: () => ImportMnePage()),
        GetPage(name: passwordSetPage, page: () => PassInitPage())
      ],
    )));
    expect(find.byType(WalletType), findsNothing);
    await tester.enterText(find.byType(TextField).first, Mne);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(find.byType(WalletType), findsOneWidget);
    await tester.tap(find.text('secp'.tr));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, passwordSetPage);
  });
}
