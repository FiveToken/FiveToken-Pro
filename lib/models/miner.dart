import 'package:hive/hive.dart';
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
    this.balance = map['rewards'] as String;
    this.lock = map['lock'] as String ?? '0';
    this.pledge = map['pledge'] as String ?? "0";
    this.available = map['available'] as String ?? "0";
    this.qualityPower = map['quality_adj_power'] as String;
    this.rewards = map['rewards'] as String;
    this.deposit = map['deposit'] as String;
    this.rawPower = map['power'] as String;
    this.percent = map['power_percent'] as String;
    this.rank = map['rank'] as int;
    this.blockCount = map['block_count'] as int;
    this.sectorSize = map['sector_size'] as int;
    this.allSectors = map['sector_count'] as int;
    this.liveSectors = map['active_sector_count'] as int;
    this.faultSectors = map['fault_sector_count'] as int;
    this.preCommitSectors = map['recover_sector_count'] as int;
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
  @HiveField(5)
  String miner;
  @HiveField(6)
  String label;
  String get key => '$address$type';
  MinerAddress(
      {this.address = '',
      this.type = '',
      this.balance = '0',
      this.time = 0,
      this.label = '',
      this.miner = '',
      this.yestodayGasFee = '0'});
  MinerAddress.fromMap(Map map) {
    address = map['address'] as String;
    type = map['type'] as String;
    balance = map['balance'] as String;
    time = map['estimate_valid_time'] as int;
    yestodayGasFee = map['yesterday_cost'] as String;
  }
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'type': type,
      'balance': balance,
      'estimate_valid_time': time,
      'yestodayGasFee': yestodayGasFee,
      'label': label
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
    block = map['blocks_rewards'] as String;
    total = map['blocks_rewards'] as String;
    worker = map['yesterday_worker_gas'] as String;
    controller = map['yesterday_controller_gas'] as String;
    sector = map['power_incr'] as String;
    pledge = map['yesterday_sector_pledge'] as String;
    profitPerTib = map['net_profit_per_tb'] as String;
    gasFee = map['gas_fee_cap'] as String;
    lucky = map['lucky'] as String;
  }
}

class MinerBalance {
  MinerSelfBalance self;
  List<MinerAddress> relatedAddress;
  MinerBalance({this.self, this.relatedAddress});
}

@HiveType(typeId: 19)
class MinerSelfBalance {
  @HiveField(0)
  String total;
  @HiveField(1)
  String available;
  @HiveField(2)
  String locked;
  @HiveField(3)
  String pledge;
  MinerSelfBalance(
      {this.total = '0',
      this.available = '0',
      this.locked = '0',
      this.pledge = '0'});
  MinerSelfBalance.fromJson(Map<String, dynamic> json) {
    total = json['total_balance'] as String;
    available = json['available_balance'] as String;
    locked = json['locked_funds'] as String;
    pledge = json['initial_pledge'] as String;
  }
}
