import 'dart:convert';
import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/message/body.dart';
import 'package:fil/pages/multi/create.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  putStore();
  mockMultibox();
  TestWidgetsFlutterBinding.ensureInitialized();
  final MethodChannel c = MethodChannel('flotus');
  c.setMockMethodCallHandler((methodCall) async {
    switch (methodCall.method) {
      case 'genCid':
        return FilAddr;
    }
  });
  $store.setWallet(
      Wallet(address: FilAddr, readonly: 1, balance: '120000000000000000'));
  var adapter = mockProvider();
  print(adapter);
  adapter
    ..onGet(FilecoinProvider.balancePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {'nonce': 1, 'balance': '120000000000000000'}
      });
    }, queryParameters: {'actor': FilAddr})
    ..onGet(FilecoinProvider.feePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          "base_fee": "100",
          "gas_limit": 786988,
          "gas_premium": "100112",
          "gas_cap": "100412",
        }
      });
    }, queryParameters: {'method': 'Exec', 'actor': FilecoinAccount.f01})
    ..onGet(FilecoinProvider.serializePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': jsonEncode({'param': ''})
      });
    }, queryParameters: {
      'raw': jsonEncode({
        'signers': [FilAddr, FilAddr, FilAddr],
        'threshold': 1,
        'unlock_duration': 0
      })
    });
  testWidgets('test render create multi page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: multiCreatePage,
      getPages: [
        GetPage(name: multiCreatePage, page: () => MultiCreatePage()),
        GetPage(name: mesBodyPage, page: () => MesBodyPage()),
      ],
    )));
    expect(find.byType(Field), findsNWidgets(3));
    await tester.tap(find.text('addMember'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(Field), findsNWidgets(4));
    await tester.enterText(find.byType(Field).first, WalletLabel);
    await tester.enterText(find.byType(Field).at(1), FilAddr);
    await tester.enterText(find.byType(Field).at(2), FilAddr);
    await tester.enterText(find.byType(Field).last, '1');
    await tester.tap(find.text('create'.tr));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(Get.currentRoute, multiCreatePage);
  });
}
