import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  var box = mockWalletbox();
  putStore();
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test wallet list and manage page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: walletSelectPage,
      getPages: [
        GetPage(name: walletSelectPage, page: () => WalletListPage()),
        GetPage(name: walletMangePage, page: () => WalletManagePage())
      ],
    ));
    expect(find.text(WalletLabel), findsOneWidget);
    await tester.tap(find.text(WalletLabel));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletMangePage);
    expect(find.byType(TapCard), findsNWidgets(4));
  });
}
