import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  var box = mockAddressBoxbox();
  Get.put(StoreController());
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test render address book index page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: addressIndexPage,
      getPages: [
        GetPage(name: addressIndexPage, page: () => AddressBookIndexPage())
      ],
    ));
    expect(find.byType(SwiperItem), findsOneWidget);
  });
}
