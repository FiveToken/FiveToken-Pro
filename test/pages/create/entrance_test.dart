import 'package:fil/pages/create/entrance.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render entance page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CreateEntrancePage(),
    ));
    expect(find.byType(TapCard), findsNWidgets(2));
  });
}
