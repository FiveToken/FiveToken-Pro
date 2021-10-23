import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MethodChannel c = MethodChannel('flotus');
  c.setMockMethodCallHandler((methodCall) async {
    switch (methodCall.method) {
      case 'secpPrivateToPublic':
        return FilAddr;
      case 'genAddress':
        return FilAddr;
    }
  });
  var box = mockWalletbox();
  when(box.containsKey(any)).thenReturn(false);
  testWidgets('test render import private page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: importPrivateKeyPage,
      getPages: [
        GetPage(name: importPrivateKeyPage, page: () => ImportPrivateKeyPage()),
        GetPage(name: passwordSetPage, page: () => PassInitPage())
      ],
    )));
    await tester.enterText(find.byType(TextField).first, FilHexPrivate);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(seconds: 5));
    expect(Get.currentRoute, passwordSetPage);
  });
}
