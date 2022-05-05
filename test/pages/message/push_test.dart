import 'dart:convert';
import 'package:fil/bloc/push/push_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/message/push.dart';
import 'package:fil/pages/sign/signBody.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../../box.dart';
import '../../provider.dart';

class MockPushBloc extends Mock implements PushBloc {}

void main() {
  var adapter = mockProvider();
  PushBloc bloc = MockPushBloc();
  var box = mockWalletbox();
  mockMessagebox();
  putStore();
  mockPushbox();
  when(box.containsKey(any)).thenReturn(true);
  var mes = SignedMessage(TMessage(), Signature(0, ''));
  adapter.onPost(FilecoinProvider.pushPath, (request) {
    request.reply(200, {'code': 200, 'data': ''});
  }, data: {'cid': '', 'raw': jsonEncode(mes.toLotusSignedMessage())});
  testWidgets('test render message push page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mesPushPage,
      getPages: [
        GetPage(
            name: mesPushPage,
            page: () => Provider(
              create: (_) => bloc..add(SetPushEvent(showDisplay: true)),
              child: MultiBlocProvider(
                  providers: [BlocProvider<PushBloc>.value(value: bloc)],
                  child: MaterialApp(
                    home: MesPushPage(),
                  )
              )
            )
        )],
    )));
    expect(find.byType(DisplayMessage), findsNothing);
    // MesPushPageState state =
    //     tester.state<MesPushPageState>(find.byType(MesPushPage));
    // state.showDetail(mes);
    await tester.pumpAndSettle();
    expect(find.byType(DisplayMessage), findsNothing);
    await tester.tap(find.text('push'.tr));
    await tester.pumpAndSettle(Duration(seconds: 5));
  });
}
