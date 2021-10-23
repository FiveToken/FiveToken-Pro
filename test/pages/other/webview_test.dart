import 'package:fil/index.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/route_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constant.dart';

void main() {
  testWidgets('test render webview page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: webviewPage, page: () => WebviewPage()),
        GetPage(name: mainPage, page: () => Container())
      ],
    ));
    Get.toNamed(webviewPage,
        arguments: {'title': WalletLabel, 'url': filscanWeb});
    await tester.pumpAndSettle();
    expect(find.text(WalletLabel), findsOneWidget);
    expect(find.byType(WebView), findsOneWidget);
  });
}
