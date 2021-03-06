import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  putStore();
  Global.cacheWallet = Wallet(type: '1');
  testWidgets('test render export private page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletPrivatekey, page: () => WalletPrivatekeyPage())
      ],
    ));
    Get.toNamed(walletPrivatekey, arguments: {
      'pk': FilPrivate,
    });
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletPrivatekey);
    expect(find.byType(KeyString), findsOneWidget);
    expect(find.byType(KeyCode), findsNothing);
    await tester.tap(find.text('code'.tr));
    await tester.pump();
    expect(find.byType(KeyString), findsNothing);
    expect(find.byType(KeyCode), findsOneWidget);
  });
}
