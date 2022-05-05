import 'package:fil/pages/other/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render about page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AboutPage(),
    ));
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
