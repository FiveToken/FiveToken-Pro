import 'package:fil/chain/provider.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/pages/message/body.dart';
import 'package:fil/pages/message/deposit.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  var box = mockWalletbox();
  putStore();
  var adapter = mockProvider();
  adapter.onPost(FilecoinProvider.buildPath, (request) {
    request.reply(200, {
      'code': 200,
      'data': {'message': TMessage().toJson()}
    });
  }, data: {
    'from': FilAddr,
    'to': '',
    'value': '1000000000000000000',
    'method': 0
  });
  when(box.values).thenReturn([]);
  testWidgets('test render deposit and body page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mesDepositPage,
      getPages: [
        GetPage(name: mesDepositPage, page: () => DepositPage()),
        GetPage(name: mesBodyPage, page: () => MesBodyPage())
      ],
    )));
    expect(find.byType(Field), findsNWidgets(4));
    DepositPageState state =
        tester.state<DepositPageState>(find.byType(DepositPage));
    state.showWallet(RechargeRadio.offLine);
    await tester.pumpAndSettle();
    expect(find.byType(WalletSelect), findsOneWidget);
    await tester.enterText(find.byType(Field).first, FilAddr);
    await tester.enterText(find.byType(Field).last, '1');
    // state.confirm(RechargeRadio.offLine);
    // await tester.pumpAndSettle();
    // expect(Get.currentRoute, mesDepositPage);
    // MesBodyPageState bodyState =
    //     tester.state<MesBodyPageState>(find.byType(MesBodyPage));
    // bodyState.showDetail();
    // await tester.pumpAndSettle();
    // expect(find.text('detail'.tr), findsOneWidget);
  });
}
