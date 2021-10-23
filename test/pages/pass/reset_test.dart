import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
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
        skKek: 'bg2YYJ1rWZrE0zgVi90aZ3k8rEA60PPz2235qBOum8c=',
        digest: 'yCjEF6kR8IgjHm/xz4GLpA==');
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
    expect(Get.currentRoute, mainPage);
  });
}
