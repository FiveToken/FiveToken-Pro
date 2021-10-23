import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../constant.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('test render qrcode', (tester) async {
    binding.window.physicalSizeTestValue = Size(360, 1000);
    binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(MaterialApp(
      home: QrImageView(WalletLabel),
    ));
    expect(find.byType(QrImage), findsOneWidget);
    await tester.tap(find.byType(QrImage));
    await tester.pumpAndSettle();
    expect(find.byType(QrImage), findsNWidgets(2));
  });
}
