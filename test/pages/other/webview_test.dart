import 'package:fil/bloc/webview/webview_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/route_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';

class MockWebviewBloc extends Mock implements WebviewBloc {}

void main() {
  WebviewBloc bloc = MockWebviewBloc();
  testWidgets('test render webview page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(
            name: webviewPage,
            page: () => Provider(
                create: (_) => bloc..add(SetWebviewEvent()),
                child: MultiBlocProvider(
                    providers: [BlocProvider<WebviewBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home: WebviewPage(),
                    )))),
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
