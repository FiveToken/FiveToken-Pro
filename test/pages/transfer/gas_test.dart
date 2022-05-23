import 'package:fil/models/gas.dart';
import 'package:fil/pages/message/gas.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../box.dart';

void main() {
  putStore();
  var gas = Gas(gasLimit: 1000, feeCap: '123', premium: '12', level: 2);
  $store.setGas(gas);
  testWidgets('test render set gas page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: mesGasPage, page: () => MessageGasPage())
      ],
    ));
    Get.toNamed(mesGasPage, arguments: {'gas': gas});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, mesGasPage);
    // await tester.tap(find.text('normal'.tr));
    // await tester.pumpAndSettle();
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, mainPage);
  });
}
