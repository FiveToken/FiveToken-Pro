import 'package:fil/models/wallet.dart';
import 'package:fil/pages/wallet/list.dart';
import 'package:fil/pages/wallet/manage.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
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
