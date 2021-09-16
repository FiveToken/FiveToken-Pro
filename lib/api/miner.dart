import 'package:fil/index.dart';

/// get miner detail info
Future<MinerMeta> getMinerInfo(String address) async {
  var empty = MinerMeta();
  try {
    var result = await fetch(
      "filscan.ActorById",
      [address],
    );
    if (result.data == null) {
      return empty;
    }
    var response = JsonRPCResponse.fromJson(result.data);

    if (response.error != null) {
      showCustomError(response.error['message']);
      return empty;
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
        return empty;
      }
    }
  } catch (e) {
    print(e);
    return empty;
  }
}

/// get miner's workers and controllers
Future<List<MinerAddress>> getMinerControllers(String addr) async {
  var result = await fetch('filscan.WalletStatisticalIndicators', [addr, '1d']);
  if (result.data == null) {
    throw Exception('get status fail');
  }
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    throw Exception('get controllers failed');
  } else {
    var res = response.result;
    if (res != null) {
      var list = res['address_balances'] ?? [];
      var box = OpenedBox.monitorInsance;
      var addressList = (list as List)
          .map((e) {
            var address = MinerAddress.fromMap(e);
            return address;
          })
          .where((v) => v.address != '')
          .toList();
      addressList.forEach((address) async {
        var cid = address.address;
        var label =
            '${address.type[0].toUpperCase()}${address.type.substring(1)}';
        if (box.containsKey(cid)) {
          label = box.get(cid).label;
        }
        if (address.type == 'owner') {
          var l = box.values
              .where((v) => v.miner == addr && v.type == 'owner')
              .toList();
          if (l.isNotEmpty) {
            var owner = l[0];
            label = owner.label;
            await box.delete(owner.cid);
          }
        }

        box.put(
            cid,
            MonitorAddress(
                cid: cid,
                miner: addr,
                label: label,
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
  if (result.data == null) {
    throw Exception('get status fail');
  }
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
    if (result.data == null) {
      return [];
    }
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
