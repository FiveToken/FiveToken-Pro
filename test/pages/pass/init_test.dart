import 'package:fil/models/wallet.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../../box.dart';
import '../../constant.dart';

void main() {
  mockWalletbox();
  mockStore();
  putStore();
  testWidgets('test render pass init page', (tester) async {
    var wallet = Wallet(address: FilAddr, label: WalletLabel, ck: FilPrivate);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: passwordSetPage, page: () => PassInitPage())
      ],
    ));
    Get.toNamed(passwordSetPage,
        arguments: {'wallet': wallet, 'create': false});
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, ValidPass);
    await tester.enterText(find.byType(TextField).last, ValidPass);
    // await tester.tap(find.byType(FlatButton));
    // await tester.pumpAndSettle();
    // expect(Get.currentRoute, '/password/set');
  });
}
