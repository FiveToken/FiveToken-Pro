import 'package:fil/routes/path.dart';
import 'package:fil/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render doc button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DocButton(
        page: mesMakePage,
      ),
    ));
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
  });
}
