import 'package:fil/models/wallet.dart';
import 'package:fil/pages/address/main.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get_instance/src/extension_instance.dart';
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
    expect(find.byType(SwiperItem), findsNothing);
  });
}
