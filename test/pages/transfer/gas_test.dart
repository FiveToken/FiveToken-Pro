import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../box.dart';

void main() {
  putStore();
  var gas = Gas(gasLimit: 1000, feeCap: '123', premium: '12',level: 2);
  $store.setGas(gas);
  testWidgets('test render set gas page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filGasPage, page: () => FilGasPage())
      ],
    ));
    Get.toNamed(filGasPage, arguments: {'gas': gas});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, filGasPage);
    await tester.tap(find.text('normal'.tr));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, mainPage);
  });
}
