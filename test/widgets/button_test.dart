import 'package:fil/index.dart';
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
