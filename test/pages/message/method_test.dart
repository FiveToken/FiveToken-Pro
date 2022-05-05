import 'package:fil/pages/message/method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render message method page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MethodSelectPage(),
    ));
    expect(find.byType(MethodSelectItem), findsNWidgets(6));
  });
}
