import 'package:fil/chain/provider.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/multi/import.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  putStore();
  mockStore();
  var box = mockMultibox();
  MultiSignWallet signWallet = MultiSignWallet();
  when(box.values).thenReturn([signWallet]);
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
