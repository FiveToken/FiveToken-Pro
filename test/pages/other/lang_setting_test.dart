import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../widgets/dialog_test.dart';

void main() {
  Global.store = MockSharedPreferences();
  testWidgets('test render setting and lang page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: setPage,
      getPages: [
        GetPage(name: langPage, page: () => LangPage()),
        GetPage(name: setPage, page: () => SetPage()),
      ],
    ));
    expect(find.byType(TapCard), findsNWidgets(5));
    await tester.tap(find.text('lang'.tr));
    await tester.pumpAndSettle();
    expect(find.byType(CardItem), findsNWidgets(2));
  });
}
