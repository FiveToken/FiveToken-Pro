
import 'package:fil/pages/message/body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render message body page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MesBodyPage(),
    ));
  });
  
}