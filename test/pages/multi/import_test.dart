import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  putStore();
  mockStore();
  var box = mockMultibox();
  when(box.containsKey(any)).thenReturn(false);
  $store.setWallet(Wallet(address: FilAddr));
  var adapter = mockProvider();
  adapter.onGet(FilecoinProvider.multiPath, (request) {
    request.reply(200, {
      "code": 200,
      "data": {
        "id": "f01234",
        "address": "f2js3pjfdmajqhqfhyggi7l6u3q6lwzrbqgnil5qq",
        "balance": "120000000000",
        "nonce": 0,
        "signers": [
          {"f04321": FilAddr},
        ],
        "approve_required": 1
      }
    });
  }, queryParameters: {'address': 'f01234'});
  testWidgets('test render multi import page ', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: multiImportPage,
      getPages: [
        GetPage(name: multiImportPage, page: () => MultiImportPage()),
        GetPage(name: multiMainPage, page: () => Container())
      ],
    )));
    expect(find.byType(Field), findsNWidgets(2));
    await tester.enterText(find.byType(Field).first, 'f01234');
    await tester.enterText(find.byType(Field).last, WalletLabel);
    await tester.tap(find.text('import'.tr));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, multiMainPage);
  });
}
