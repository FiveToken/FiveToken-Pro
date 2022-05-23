import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/create/mne.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/main/messageItem.dart';
import 'package:fil/pages/main/offline.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../box.dart';
import '../../provider.dart';
import '../../size.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  setString(any, any2) {}
  getString(any){
    return 'binance';
  }
}



void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  // Global.onlineMode = true;
  var adapter = mockProvider();
  adapter
    ..onGet(FilecoinProvider.balancePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          "balance" : '100',
        }
      });
    }, queryParameters: {'actor': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema'})
    ..onGet(FilecoinProvider.pricePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          "data" : 18.87530856159344,
        }
      });
    }, queryParameters: {'id': 'filecoin', 'vs': 'usd'})
    ..onGet(FilecoinProvider.messageListPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': [
          {
            "mid" : "172990600216",
            "block_epoch" : 1729906,
            "block_time" : 1650203580,
            "receipt_epoch" : 1729907,
            "index" : 216,
            "cid" : "bafy2bzacedjfayz22gnuotadp3t4m65l7go3p6irhdwp7c7nj3ukdtrr4k2rq",
            "origin_cid" : "bafy2bzaceb47rvolkubfrhxvfpfcf6ilkzvfhmbwcpsukuaja75u6o5bx66ne",
            "block_cids": ['{bafy2bzacecspu7ofnd4rombm5kwd4jgxv5m5ztqrtypuweblbsdexrekzrraq}'],
            "version" : 0,
            "from" : "f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema",
            "from_actor_id" : "f0217500",
            "from_actor_address" : "f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema",
            "from_actor_type" : "account",
            "to" : "f01806630",
            "to_actor_id" : "f01806630",
            "to_actor_address" : "f2h35wuh7mk3pic453rwawp6p7s7go6q47vo23eqy",
            "to_actor_type" : "multisig",
            "nonce" : 633,
            "value" : "1100000000000",
            "gas_fee_cap" : "4591381095",
            "gas_premium" : "130126",
            "gas_limit" : 757035,
            "required_funds" : "0",
            "exit_code" : 0,
            "gas_used" : 468468,
            "signature_type" : "secp256k1",
            "signature_data" : "jc1+GDVOwocxEmAixKf8eLZXNh1UK657nmG0VhkBeKc9tmSLZhz5JVoo0eUcJ37mjerEr5YAESxp2LBhVUR1hAA=",
            "base_fee_burn" : "146336502996684",
            "over_estimation_burn" : "46510697878385",
            "miner_penalty" : "0",
            "miner_tip" : "98509936410",
            "refund" : "3282890476441846",
            "gas_refund" : 139672,
            "gas_burned" : 148895,
            "base_fee" : "312372463",
            "method_name" : "Send",
            "source" : "infura",
            "gas_fee" : "192945710811479",
            "created_at" : "2022-04-17T21:53:31.480879Z"
          }
        ]
      });
    }, queryParameters: {
      'actor': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      'mid': '',
      'direction': 'down'
    });
  var box = mockWalletbox();
  when(box.values).thenReturn([]);
  final StoreMessage message = StoreMessage.fromJson({
    'from': '',
    'to': '',
    'nonce': 0,
    'height': 0,
    'value': '',
    'pending': 1,
    'methodName': '',
    'allGasFee': '',
    'signedCid': '',
  });
  var messagebox = mockMessagebox();
  when(messagebox.values).thenReturn([]);
  print(Global.onlineMode);
  testWidgets('test MainPage page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainPage(),
    ));
    await tester.pumpAndSettle();
  });

  testWidgets('test MainPage page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OfflineWallet(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MneItem), findsNothing);
    expect(find.text('know'.tr), findsNothing);
  });

  // testWidgets('test MainPage online page', (tester) async {
  //   await tester.pumpWidget(MaterialApp(
  //     home: OnlineWallet(),
  //   ));
  //   await tester.pumpAndSettle();
  //   // expect(find.byType(MneItem), findsNothing);
  //   // expect(find.text('know'.tr), findsNothing);
  // });
}
