import 'dart:convert';
import 'package:fil/bloc/sign/sign_bloc.dart';
import 'package:fil/bloc/unsign/unsign_bloc.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/sign/sign.dart';
import 'package:fil/pages/sign/signBody.dart';
import 'package:fil/pages/sign/signed.dart';
import 'package:fil/pages/sign/unsigned.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../../box.dart';
import '../../constant.dart';
import '../../sys.dart';

class MockSignBloc extends Mock implements SignBloc {}

class MockUnsignBloc extends Mock implements UnsignBloc {}
void main() {
  SignBloc bloc = MockSignBloc();
  UnsignBloc bloc1 = MockUnsignBloc();
  TestWidgetsFlutterBinding.ensureInitialized();
  mockStore();
  mockNoncebox();
  mockClipboard();
  putStore();
  final MethodChannel c = MethodChannel('flotus');
  c.setMockMethodCallHandler((methodCall) async {
    switch (methodCall.method) {
      case 'messageCid':
        return '';
      case 'secpSign':
        return '';
    }
  });
  var unsigned = TMessage(
      from: FilAddr,
      to: FilAddr,
      value: '1',
      gasFeeCap: '10',
      gasLimit: 10,
      gasPremium: '10',
      method: 0,
      nonce: 1);
  var wallet = Wallet(
      address: FilAddr,
      label: WalletLabel,
      ck: FilPrivate,
      skKek: 'bg2YYJ1rWZrE0zgVi90aZ3k8rEA60PPz2235qBOum8c=');
  $store.setWallet(wallet);
  setUp(() async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(unsigned.toLotusMessage())));
  });
  testWidgets('test render message sign page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: signIndexPage,
      getPages: [
        GetPage(
            name: signIndexPage,
            page: () => Provider(
                create: (_) => bloc..add(SetSignEvent(showSigned: false)),
                child: MultiBlocProvider(
                    providers: [BlocProvider<SignBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home: SignIndexPage(),
                    ))))
      ],
    )));
    expect(find.byType(UnsignedMessage), findsOneWidget);
    // await tester.tap(find.text('copyMes'.tr));
    // await tester.pumpAndSettle();
    // expect(find.byType(DisplayMessage), findsOneWidget);
    // await tester.tap(find.text('advanced'.tr));
    // await tester.pumpAndSettle();
    // expect(find.byType(DisplayMessage), findsNothing);
    // expect(find.byType(EditableMessage), findsOneWidget);
    // await tester.tap(find.text('signBtn'.tr));
    // await tester.pumpAndSettle();
    // expect(find.byType(PassDialog), findsOneWidget);
    // await tester.enterText(
    //     find.descendant(
    //         of: find.byType(PassDialog), matching: find.byType(TextField)),
    //     ValidPass);
    // await tester.tap(find.text('sure'.tr));
    // await tester.pumpAndSettle(Duration(seconds: 5));
    // expect(find.byType(SignedMessageBody), findsOneWidget);
  });
}
