import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
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
