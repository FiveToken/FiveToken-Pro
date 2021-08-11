import 'package:fil/index.dart';

/// get miner detail info
Future<MinerMeta> getMinerInfo(String address) async {
  try {
    var result = await fetch(
      "filscan.ActorById",
      [address],
    );
    var response = JsonRPCResponse.fromJson(result.data);

    if (response.error != null) {
      showCustomError(response.error['message']);
      return MinerMeta();
    } else {
      var res = response.result;
      if (res != null) {
        var basic = res['basic'] ?? {};
        var extra = res['extra'] ?? {};
        return MinerMeta(
            balance: basic['balance'] ?? '0',
            pledge: extra['init_pledge'] ?? '0',
            deposit: extra['pre_deposits'] ?? '0',
            qualityPower: extra['quality_adjust_power'] ?? '0',
            rewards: basic['rewards'] ?? '0',
            available: extra['available_balance'] ?? '0',
            rank: extra['rank'],
            percent: extra['power_percent'].toString(),
            rawPower: extra['power'],
            blockCount: basic['block_count'],
            sectorSize: extra['sector_size'],
            allSectors: extra['sector_count'],
            faultSectors: extra['fault_sector_count'],
            liveSectors: extra['live_sector_count'],
            preCommitSectors: extra['recover_sector_count'],
            lock: extra['locked_funds'] ?? '0');
      } else {
        return MinerMeta();
      }
    }
  } catch (e) {
    print(e);
    return MinerMeta();
  }
}

/// get miner's workers and controllers
Future<List<MinerAddress>> getMinerControllers(String addr) async {
  var result = await fetch('filscan.WalletStatisticalIndicators', [addr, '1d']);
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    throw Exception('get controllers failed');
  } else {
    var res = response.result;
    if (res != null) {
      var list = res['address_balances'] ?? [];
      var box = Hive.box<MonitorAddress>(monitorBox);
      var addressList = (list as List).map((e) {
        var address = MinerAddress.fromMap(e);
        return address;
      }).toList();
      addressList.forEach((address) {
        var cid = address.address;
        box.put(
            cid,
            MonitorAddress(
                cid: cid,
                miner: addr,
                label:
                    '${address.type[0].toUpperCase()}${address.type.substring(1)}',
                threshold: '-1',
                type: address.type));
      });
      return addressList;
    } else {
      throw Exception('get controllers failed');
    }
  }
}

/// get miner yesterday's statistical indicators
Future<MinerHistoricalStats> getMinerYestodayInfo(String address) async {
  var result = await fetch('filscan.StatisticalIndicatorsUnite', [
    [address],
    '1d',
    1
  ]);
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    throw Exception('get status fail');
  } else {
    var res = response.result;
    if (res != null) {
      return MinerHistoricalStats.fromMap(res);
    } else {
      throw Exception('get status fail');
    }
  }
}
/// get miner's active workers 
Future<List<String>> getActiveMiners(String address) async {
  try {
    var result = await fetch(
      "filscan.ActorById",
      [address],
    );
    var response = JsonRPCResponse.fromJson(result.data);
    if (response.error != null) {
      showCustomError(response.error['message']);
      return [];
    } else {
      var res = response.result;
      if (res != null) {
        var rawList = res['active_miners'];
        var list =
            rawList is List ? rawList.map((e) => e.toString()).toList() : [];
        return list;
      } else {
        return [];
      }
    }
  } catch (e) {
    return [];
  }
}
