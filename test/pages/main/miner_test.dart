import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../box.dart';
import '../../provider.dart';
class MockSharedPreferences extends Mock implements SharedPreferences {
  setString(any, any2) {}
  getString(any) {
    return '';
  }
}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  var box = MockminerBalanceInstance();
  var box2 = MockminerStatisticInstance();
  var adapter = mockProvider();
  Global.store = store;
  var balance = MinerSelfBalance();
  when(box.values).thenReturn([balance]);
  var history = MinerHistoricalStats();
  when(box2.values).thenReturn([history]);
  $store.setWallet(Wallet(address: 'f01234', walletType: 2));
  adapter
    ..onGet(FilecoinProvider.pricePath, (request) {
      request.reply(200, {
        'code': 200,
        'data': 17.78
      });
    }, queryParameters: {'id': 'filecoin', 'vs': 'usd'})
    ..onGet(FilecoinProvider.minerPowerPath, (request) {
      request.reply(200, {
        'code': 200,
        'data': {
          "blocks": "0",
          "blocks_rewards": "0",
          "gas_fee_cap": "29488223907811210",
          "lucky": "0",
          "miner_precommit_deposits": "0",
          "miners": "",
          "mining_efficiency": "0",
          "net_profit": "0",
          "net_profit_per_tb": "0",
          "packing_penalty": "0",
          "power_incr": "0",
          "power_penalty": "0",
          "power_ratio": "0",
          "running_days": 0,
          "sector_incr": "0",
          "sector_number_incr": "0",
          "sector_ratio": "0",
          "sigma_win_count": "0",
          "yesterday_controller_gas": "0",
          "yesterday_sector_pledge": "0",
          "yesterday_worker_gas": "0"
        }
      });
    }, queryParameters: {'address': 'f01234'})
     ..onGet(FilecoinProvider.minerBalancePath, (request) {
       request.reply(200, {
         'code': 200,
         'data': {
           "id": "f01234",
           "total_balance": "9041999995822808975518",
           "available_balance": "0",
           "locked_funds": "1389109613896391555493",
           "initial_pledge": "7652890381926417420025",
           "pre_commit_deposits": "0"
         }
       });
     }, queryParameters: {'address': 'f01234'})
     ..onGet(FilecoinProvider.minerMetaPath, (request){
       request.reply(200, {
         'code': 200,
         'data': {
           "rewards": "10611717195343826253869",
           "block_count": 459,
           "epoch": 1751339,
           "power": "1065632925745152",
           "quality_adj_power": "1091767989469184",
           "sector_size": 34359738368,
           "sector_count": 31731,
           "active_sector_count": 31014,
           "fault_sector_count": 0,
           "live_sector_count": 31014,
           "power_percent": "0.005799999926239252",
           "recover_sector_count": 0,
           "terminated_sector_count": 717,
           "rank": 2415
         }
       });
     }, queryParameters: {'address': 'f01234'});
  testWidgets('test main miner page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MinerAddressStats(),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}