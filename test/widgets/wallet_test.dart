import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../constant.dart';

void main() {
  testWidgets('test render wallet select', (tester) async {
    var type = '';
    await tester.pumpWidget(GetMaterialApp(
      home: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              showWalletSelector(context, (t) {
                type = t;
              });
            },
            child: Text(WalletLabel),
          );
        },
      ),
    ));
    await tester.tap(find.text(WalletLabel));
    await tester.pumpAndSettle();
    expect(find.byType(TapCard), findsNWidgets(2));
    await tester.tap(find.text('bls'.tr));
    await tester.pumpAndSettle();
    expect(type, '3');
  });
}
