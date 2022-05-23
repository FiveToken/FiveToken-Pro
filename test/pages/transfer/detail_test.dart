import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';
import '../../constant.dart';
import '../../provider.dart';

void main() {
  var adapter = mockProvider();
  testWidgets('test render pending message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 1,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    await tester.pumpAndSettle();
    expect(find.byType(ChainMeta), findsNothing);
  });
  testWidgets('test render complete message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {'code': 200, 'data': {}});
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.byType(ChainMeta), findsOneWidget);
  });
  testWidgets('test render withdraw message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          'block_epoch': 1,
          'method_name': FilecoinMethod.withdraw,
          'params_json': '{"AmountRequested":"1000"}',
          'cid': '',
          'from': '',
          'to': ''
        }
      });
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.text('withdrawNum'.tr), findsNothing);
  });
  testWidgets('test render change owner message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          'block_epoch': 1,
          'method_name': FilecoinMethod.changeOwner,
          'params_json': null,
          'cid': '',
          'from': '',
          'to': ''
        }
      });
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.text('newOwner'.tr), findsNothing);
  });
  testWidgets('test render create miner message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          'block_epoch': 1,
          'method_name': FilecoinMethod.createMiner,
          'params_json': '{"Owner":"","Worker":""}',
          'return_json': '{"IDAddress":""}',
          'cid': '',
          'from': '',
          'to': ''
        }
      });
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.text('owner'.tr), findsNothing);
  });
  testWidgets('test render exec message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          'block_epoch': 1,
          'method_name': FilecoinMethod.exec,
          'return_json': '{"IDAddress":""}',
          'cid': '',
          'from': '',
          'to': ''
        }
      });
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.text('multisig'.tr), findsNothing);
  });
  testWidgets('test render change worker message detail page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: mainPage,
      getPages: [
        GetPage(name: mainPage, page: () => Container()),
        GetPage(name: filDetailPage, page: () => FilDetailPage())
      ],
    )));
    var mes = StoreMessage(
        from: FilAddr,
        to: FilAddr,
        value: '100000000',
        signedCid: '',
        pending: 0,
        exitCode: 0);
    Get.toNamed(filDetailPage, arguments: mes);
    adapter.onGet(FilecoinProvider.pushPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          'block_epoch': 1,
          'method_name': FilecoinMethod.changeWorker,
          'params_json': '{"NewWorker":"","NewControlAddrs":[]}',
          'cid': '',
          'from': '',
          'to': ''
        }
      });
    }, queryParameters: {'cid': ''});
    await tester.pumpAndSettle();
    expect(find.text('controller'.tr), findsNothing);
  });
}
