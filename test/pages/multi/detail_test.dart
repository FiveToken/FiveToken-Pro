import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  putStore();
  $store.setMultiWallet(
      MultiSignWallet(id: 'f01234', signers: [FilAddr, FilAddr]));
  testWidgets('test render multi detail page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MultiDetailPage(),
    ));
    expect(find.text(FilAddr), findsNWidgets(2));
  });
}
