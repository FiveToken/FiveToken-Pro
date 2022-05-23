import 'package:fil/chain/provider.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/message/make.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/field.dart';
import 'package:flutter/material.dart';
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
  var minerBox = mockMinerAddressbox();
  var pushBox = mockPushbox();

  var adapter = mockProvider();
  when(pushBox.values).thenReturn([]);
  $store.setWallet(Wallet(address: 'f01234', walletType: 2));
  when(minerBox.values).thenReturn(
      [MinerAddress(address: FilAddr, type: 'owner', miner: 'f01234')]);
  adapter.onPost(FilecoinProvider.buildPath, (request) {
    request.reply(200, {
      'code': 200,
      'data': {
        'cid': 'bafy2bzacedhgqaol6rcwjebbcovudjdgvfetmqe62dxpoc2potfox7uooowew',
        'message': TMessage().toLotusMessage()
      }
    });
  }, data: {
    'from': FilAddr,
    'to': 'f01234',
    'value': '0',
    'method': '16',
    'params': '{"AmountRequested":"1"}'
  });
  adapter
    ..onGet(FilecoinProvider.balancePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {'balance': '1200000000000000000', 'nonce': 1}
      });
    }, queryParameters: {'actor': FilAddr})
    ..onGet(FilecoinProvider.balancePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {'balance': '1200000000000000000', 'nonce': 0}
      });
    }, queryParameters: {'actor': 'f01234'});

  testWidgets('test render message make page ', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => Container()),
        GetPage(name: mesMakePage, page: () => MesMakePage()),
      ],
    )));
    Get.toNamed(mesMakePage, arguments: {
      'type': MessageType.MinerManage,
      'method': '16',
      'to': 'f01234'
    });
    await tester.pumpAndSettle();
    expect(Get.currentRoute, mesMakePage);
    MesMakePageState state =
        tester.state<MesMakePageState>(find.byType(MesMakePage));
    expect(state.fromBalance.toString(), '1200000000000000000');
    expect(state.minerBalance.toString(), '1200000000000000000');
    await tester.enterText(
        find.ancestor(of: find.text('amount'.tr), matching: find.byType(Field)),
        '1');
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(Get.currentRoute, mesMakePage);
  });
}
