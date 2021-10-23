import 'package:fil/index.dart';
import 'package:fil/pages/address/wallet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  var box = mockWalletbox();
  Global.onlineMode = true;
  Get.put(StoreController());
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test render address book wallet select page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: addressWalletPage,
      getPages: [
        GetPage(name: addressWalletPage, page: () => AddressBookWalletSelect())
      ],
    ));
    expect(find.text(WalletLabel), findsOneWidget);
  });
}
