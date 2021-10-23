import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
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
