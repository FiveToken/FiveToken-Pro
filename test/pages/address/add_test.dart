import 'package:fil/models/wallet.dart';
import 'package:fil/pages/address/add.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import '../../box.dart';
import '../../constant.dart';

void main() {
  var box = mockAddressBoxbox();
  when(box.containsKey(any)).thenReturn(false);
  testWidgets('test render add address page', (tester) async {
    var wal = Wallet(address: FilAddr, label: WalletLabel);
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: addressAddPage, page: () => AddressBookAddPage()),
        GetPage(name: initLangPage, page: () => SelectLangPage()),
      ],
    )));
    Get.toNamed(addressAddPage, arguments: {'wallet': wal});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, addressAddPage);
    await tester.enterText(find.byType(TextField).first, FilAddr);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(Get.currentRoute, initLangPage);
  });
}
