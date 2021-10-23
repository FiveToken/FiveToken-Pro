import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

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

  testWidgets('test render import readonly page', (tester) async {
    adapter
      ..onGet(FilecoinProvider.typePath, (request) {
        request.reply(200, {
          'code': 200,
          'data': {'type': FilecoinAddressType.account}
        });
      }, queryParameters: {'address': FilAddr});
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: readonlyPage,
      getPages: [
        GetPage(
          name: readonlyPage,
          page: () => ReadonlyPage(),
        ),
        GetPage(
          name: mainPage,
          page: () => Container(),
        ),
      ],
    )));
    await tester.enterText(find.byType(TextField).first, FilAddr);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect($store.addr, FilAddr);
  });
}
