
import 'package:fil/pages/other/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';

void main() {
  var box = mockWalletbox();
  when(box.values).thenReturn([]);
  testWidgets('test render notification page', (tester)async{
    await tester.pumpWidget(MaterialApp(
      home: NotificationPage(),
    ));
  });
}