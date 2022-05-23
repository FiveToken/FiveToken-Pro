import 'package:fil/pages/other/discovery.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render discovery page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DiscoveryPage(),
    ));
    expect(find.byType(TapCard), findsNWidgets(2));
  });
}
