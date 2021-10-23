import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  putStore();
  mockNoncebox();
  var pushBox = mockPushbox();
  when(pushBox.values).thenReturn([]);
  var adapter = mockProvider();
  adapter
    ..onGet(FilecoinProvider.balancePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {'nonce': 1}
      });
    }, queryParameters: {'actor': FilAddr})
    ..onGet(FilecoinProvider.feePath, (request) {},
        queryParameters: {'method': 'Send', 'actor': FilAddr});
  var wal = Wallet(
      address: FilAddr,
      label: WalletLabel,
      ck: FilPrivate,
      balance: '100000000000000000',
      skKek: 'bg2YYJ1rWZrE0zgVi90aZ3k8rEA60PPz2235qBOum8c=',
      digest: 'yCjEF6kR8IgjHm/xz4GLpA==');
  $store.setWallet(wal);
  testWidgets('test render transfer page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filTransferPage, page: () => FilTransferNewPage())
      ],
    )));
    Get.toNamed(filTransferPage,
        arguments: {'to': 'f1jsqbhvcw77fht45pv5au5com4f5fzjj2sxlceiy'});
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '0.1');
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmSheet), findsOneWidget);
    await tester.tap(find.text('send'.tr).last);
    await tester.pumpAndSettle();
    expect(find.byType(PassDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, ValidPass);
    await tester.tap(find.text('sure'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(PassDialog), findsNothing);
  });
}
