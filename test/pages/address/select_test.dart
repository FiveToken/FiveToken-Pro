import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  var box = mockAddressBoxbox();
  Get.put(StoreController());
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test render address book select page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: addressSelectPage,
      getPages: [
        GetPage(name: addressSelectPage, page: () => AddressBookSelectPage())
      ],
    ));
    expect(find.text(WalletLabel), findsOneWidget);
  });
}
