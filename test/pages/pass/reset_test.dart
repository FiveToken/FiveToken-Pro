import 'package:fil/models/wallet.dart';
import 'package:fil/pages/pass/reset.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  mockWalletbox();
  mockStore();
  putStore();
  testWidgets('test render pass reset page', (tester) async {
    var wallet = Wallet(
        address: FilAddr,
        label: WalletLabel,
        ck: FilPrivate,
        skKek: 'bg2YYJ1rWZrE0zgVi90aZ3k8rEA60PPz2235qBOum8c=');
    $store.setWallet(wallet);
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: passwordResetPage, page: () => PassResetPage())
      ],
    )));
    Get.toNamed(
      passwordResetPage,
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    await tester.enterText(find.byType(TextField).first, ValidPass);
    await tester.enterText(find.byType(TextField).at(1), ValidPass);
    await tester.enterText(find.byType(TextField).last, ValidPass);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(Get.currentRoute, '/password/reset');
  });
}
