import 'package:fil/index.dart';
part 'miner.g.dart';

@HiveType(typeId: 9)
class MinerMeta {
  @HiveField(0)
  String balance;
  @HiveField(1)
  String lock;
  @HiveField(2)
  String pledge;
  @HiveField(3)
  String deposit;
  @HiveField(4)
  String available;
  @HiveField(5)
  String qualityPower;
  @HiveField(6)
  String rewards;
  @HiveField(7)
  String rawPower;
  @HiveField(8)
  String percent;
  @HiveField(9)
  num rank;
  @HiveField(10)
  num blockCount;
  @HiveField(11)
  num sectorSize;
  @HiveField(12)
  num allSectors;
  @HiveField(13)
  num liveSectors;
  @HiveField(14)
  num faultSectors;
  @HiveField(15)
  num preCommitSectors;
  MinerMeta(
      {this.balance = '0',
      this.lock = '0',
      this.pledge = '0',
      this.available = '0',
      this.qualityPower = '0',
      this.rewards = '0',
      this.deposit = '0',
      this.rawPower = '0',
      this.percent = '0',
      this.blockCount = 0,
      this.sectorSize = 0,
      this.allSectors = 0,
      this.rank,
      this.liveSectors = 0,
      this.faultSectors = 0,
      this.preCommitSectors = 0});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'balance': balance,
      'lock': lock,
      'pledge': pledge,
      'available': available,
      'qualityPower': qualityPower,
      'rewards': rewards,
      'deposit': deposit,
      'rawPower': rawPower,
      'percent': percent,
      'rank': rank,
      'blockCount': blockCount,
      'sectorSize': sectorSize,
      'allSectors': allSectors,
      'liveSectors': liveSectors,
      'faultSectors': faultSectors,
      'preCommitSectors': preCommitSectors
    };
  }

  MinerMeta.fromMap(Map<String, dynamic> map) {
    this.balance = map['balance'];
    this.lock = map['lock'];
    this.pledge = map['pledge'];
    this.available = map['available'];
    this.qualityPower = map['qualityPower'];
    this.rewards = map['rewards'];
    this.deposit = map['deposit'];
    this.rawPower = map['rawPower'];
    this.percent = map['percent'];
    this.rank = map['rank'];
    this.blockCount = map['blockCount'];
    this.sectorSize = map['sectorSize'];
    this.allSectors = map['allSectors'];
    this.liveSectors = map['liveSectors'];
    this.faultSectors = map['faultSectors'];
    this.preCommitSectors = map['preCommitSectors'];
  }
}

@HiveType(typeId: 10)
class MinerAddress {
  @HiveField(0)
  String address;
  @HiveField(1)
  String type;
  @HiveField(2)
  String balance;
  @HiveField(3)
  int time;
  @HiveField(4)
  String yestodayGasFee;
  MinerAddress(
      {this.address = '', this.type = '', this.balance = '0', this.time = 0});
  MinerAddress.fromMap(Map map) {
    address = map['address'];
    type = map['address_type'];
    balance = map['balance'];
    time = map['estimate_valid_time'];
    yestodayGasFee = map['yesterdayGasFee'];
  }
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'address_type': type,
      'balance': balance,
      'estimate_valid_time': time,
      'yestodayGasFee': yestodayGasFee
    };
  }
}

@HiveType(typeId: 11)
class MinerHistoricalStats {
  @HiveField(0)
  String block;
  @HiveField(1)
  String total;
  @HiveField(2)
  String worker;
  @HiveField(3)
  String controller;
  @HiveField(4)
  String sector;
  @HiveField(5)
  String pledge;
  @HiveField(6)
  String profitPerTib;
  @HiveField(7)
  String gasFee;
  @HiveField(8)
  String lucky;
  MinerHistoricalStats(
      {this.block = '0',
      this.total = '0',
      this.worker = '0',
      this.controller = '0',
      this.sector = '0',
      this.profitPerTib = '',
      this.gasFee = '',
      this.lucky = '',
      this.pledge = '0'});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'block': block,
      'total': total,
      'worker': worker,
      'controller': controller,
      'sector': sector,
      'pledge': pledge
    };
  }

  MinerHistoricalStats.fromMap(Map<String, dynamic> map) {
    block = map['blocks_rewards'];
    total = map['blocks_rewards'];
    worker = map['yesterday_worker_gas'];
    controller = map['yesterday_controller_gas'];
    sector = map['power_incr'];
    pledge = map['yesterday_sector_pledge'];
    profitPerTib = map['net_profit_per_tb'];
    gasFee = map['gas_fee_cap'];
    lucky = map['lucky'];
  }
}

@HiveType(typeId: 12)
class MinerStats {
  @HiveField(0)
  MinerHistoricalStats historicalStats;
  @HiveField(1)
  List<MinerAddress> addressList;
  @HiveField(2)
  String owner;
  MinerStats({this.historicalStats, this.addressList, this.owner = ''})
      : assert(historicalStats != null),
        assert(addressList != null);
  Map<String, dynamic> toJson() {
    return {
      'addressList': addressList,
      'owner': owner,
      'historicalStats': historicalStats.toJson()
    };
  }

  MinerStats.fromMap(Map<String, dynamic> map) {
    this.historicalStats = MinerHistoricalStats.fromMap(map['historicalStats']);
    this.addressList = (map['addressList'] as List<dynamic>)
        .map((e) => MinerAddress.fromMap(e))
        .toList();
    this.owner = map['owner'];
  }
}

@HiveType(typeId: 13)
class MinerInfo {
  @HiveField(0)
  MinerMeta meta;
  @HiveField(1)
  MinerStats stats;
  MinerInfo({this.meta, this.stats});
}

class InnerMiner {
  num totalPower,
      rewards,
      expected,
      yesIncrease,
      yesIncreasePercent,
      yesGas,
      yesPledge,
      pledge,
      workerBalance,
      workerConsume,
      windowBalance,
      yesCtrlConsume,
      preCtlBalance,
      preTime,
      proveCtrlBalance,
      proveTime;
  String updateTime, actor;
  InnerMiner(
      {this.totalPower = 0,
      this.rewards = 0,
      this.expected = 0,
      this.yesIncrease = 0,
      this.yesIncreasePercent = 0,
      this.yesGas = 0,
      this.yesPledge = 0,
      this.pledge = 0,
      this.workerBalance = 0,
      this.workerConsume = 0,
      this.windowBalance = 0,
      this.yesCtrlConsume = 0,
      this.preCtlBalance = 0,
      this.preTime = 0,
      this.proveCtrlBalance = 0,
      this.proveTime = 0,
      this.updateTime = '',
      this.actor = ''});
  InnerMiner.fromMap(Map<String, dynamic> map) {
    this.totalPower = map['current_power'];
    this.rewards = map['yesterday_block_rewards'];
    this.expected = map['expected'];
    this.yesIncrease = map['yesterday_increased_power'];
    this.yesIncreasePercent = map['yesterday_increased_percent'];
    this.yesGas = map['yesterday_mining_service_charge'];
    this.yesPledge = map['yesterday_prove_controller_pledge_expend'];
    this.pledge = map['pledge'];
    this.workerBalance = map['f3_balance'];
    this.workerConsume = map['yesterday_worker_consumed'];
    this.windowBalance = map['windowposter_balance'];
    this.yesCtrlConsume = map['yesterday_controller_consumed'];
    this.preCtlBalance = map['pre_controller_balance'];
    this.preTime = map['expected_pre_controller_consumed_in_hours'];
    this.proveCtrlBalance = map['prove_controller_balance'];
    this.proveTime = map['expected_prove_controller_consumed_in_hours'];
    this.updateTime = map['update_time'];
    this.actor = map['actor'];
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'current_power': this.totalPower,
      'yesterday_block_rewards': this.rewards,
      'expected': this.expected,
      'yesterday_increased_power': this.yesIncrease,
      'yesterday_increased_percent': this.yesIncreasePercent,
      'yesterday_mining_service_charge': this.yesGas,
      'yesterday_prove_controller_pledge_expend': this.yesPledge,
      'pledge': this.pledge,
      'f3_balance': this.workerBalance,
      'yesterday_worker_consumed': this.workerConsume,
      'windowposter_balance': this.windowBalance,
      'yesterday_controller_consumed': this.yesCtrlConsume,
      'pre_controller_balance': this.preCtlBalance,
      'expected_pre_controller_consumed_in_hours': this.preTime,
      'prove_controller_balance': this.proveCtrlBalance,
      'expected_prove_controller_consumed_in_hours': this.proveTime,
      'update_time': this.updateTime,
      'actor': this.actor,
    };
  }
}
