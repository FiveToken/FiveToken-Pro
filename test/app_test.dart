
import 'package:fil/app.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'box.dart';
import 'constant.dart';

void main() {
  var box = mockWalletbox();
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test App page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: App(initModePage),
    ));
  });
}