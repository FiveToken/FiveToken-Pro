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
        return '';
      case 'genAddress':
        return FilAddr;
    }
  });
  var box = mockWalletbox();
  when(box.containsKey(any)).thenReturn(false);
  testWidgets('test render import mne page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: importMnePage,
      getPages: [
        GetPage(name: importMnePage, page: () => ImportMnePage()),
        GetPage(name: passwordSetPage, page: () => PassInitPage())
      ],
    )));
    expect(find.byType(WalletType), findsNothing);
    await tester.enterText(find.byType(TextField).first, Mne);
    await tester.enterText(find.byType(TextField).last, WalletLabel);
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(find.byType(WalletType), findsOneWidget);
    await tester.tap(find.text('secp'.tr));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, passwordSetPage);
  });
}
