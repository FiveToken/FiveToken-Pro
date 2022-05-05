import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/create/miner.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';
import '../../widgets/dialog_test.dart';

void main() {
  var walletBox = mockWalletbox();
  var store = MockSharedPreferences();
  var adapter = mockProvider();
  Global.store = store;
  Get.put(StoreController());
  when(walletBox.containsKey(any)).thenReturn(false);
  testWidgets('test render import miner page', (tester) async {
    var miner = 'f01234';
    adapter.onGet(FilecoinProvider.typePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {'type': FilecoinAddressType.miner}
      });
    }, queryParameters: {'address': 'f01234'});
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: minerPage,
      getPages: [
        GetPage(name: minerPage, page: () => MinerPage()),
        GetPage(name: mainPage, page: () => Container()),
      ],
    )));
    await tester.enterText(find.byType(TextField).first, miner);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect($store.addr, miner);
  });
}
