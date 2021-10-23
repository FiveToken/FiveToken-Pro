import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../provider.dart';

void main() {
  var adapter = mockProvider();
  var box = mockWalletbox();
  mockMessagebox();
  putStore();
  mockPushbox();
  when(box.containsKey(any)).thenReturn(true);
  var mes = SignedMessage(TMessage(), Signature(0, ''));
  adapter.onPost(FilecoinProvider.pushPath, (request) {
    request.reply(200, {'code': 200, 'data': ''});
  }, data: {'cid': '', 'raw': jsonEncode(mes.toLotusSignedMessage())});
  testWidgets('test render message push page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mesPushPage,
      getPages: [GetPage(name: mesPushPage, page: () => MesPushPage())],
    )));
    expect(find.byType(DisplayMessage), findsNothing);
    MesPushPageState state =
        tester.state<MesPushPageState>(find.byType(MesPushPage));
    state.showDetail(mes);
    await tester.pumpAndSettle();
    expect(find.byType(DisplayMessage), findsOneWidget);
    await tester.tap(find.text('push'.tr));
    await tester.pumpAndSettle(Duration(seconds: 5));
  });
}
