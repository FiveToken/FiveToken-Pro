import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, mainPage);
  });
}
