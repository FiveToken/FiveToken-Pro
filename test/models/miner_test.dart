import 'package:fil/models/host.dart';
import 'package:fil/models/miner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      'rewards': '1',
      'lock': '',
      'pledge': '',
      'available': '',
      'quality_adj_power': '',
      'rewards': '',
      'deposit': '',
      'power': '',
      'power_percent': '',
      'rank': 1,
      'block_count': 0,
      'sector_size': 0,
      'sector_count': 0,
      'active_sector_count': 0,
      'fault_sector_count': 0,
      'recover_sector_count': 0
    };
    var storeMes = MinerMeta.fromMap(json);
    var res = storeMes.toJson();
    expect(storeMes.rank, 1);

    var minerAddress = MinerAddress.fromMap({
      'address':'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      'type':'miner',
      'balance':'',
      'estimate_valid_time':1,
      'yesterday_cost':''
    });
    var minerAddressJson  = minerAddress.toJson();

    expect(minerAddress.time, 1);
    expect(minerAddress.key, 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oemaminer');
    expect(minerAddressJson['address'], 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');

    var minerHistoricalStats = MinerHistoricalStats.fromMap({
      'blocks_rewards': '',
      'yesterday_worker_gas': '',
      'yesterday_controller_gas': '',
      'power_incr': '',
      'yesterday_sector_pledge': '',
      'net_profit_per_tb': '',
      'gas_fee_cap': '',
      'lucky': '1'
    });
    var MinerHistoricalStatsJson = minerHistoricalStats.toJson();
    expect(minerHistoricalStats.lucky, '1');
    expect(MinerHistoricalStatsJson['total'], '');

    var res1 = MinerSelfBalance.fromJson({
      'total_balance': '1',
      'available_balance': '0',
      'locked_funds': '0',
      'initial_pledge': '0'
    });
    expect(res1.total, '1');

    var minerBalance = MinerBalance(
      self: res1,
      relatedAddress: [minerAddress],
    );
    expect(minerBalance.relatedAddress, [minerAddress]);
  });
}
