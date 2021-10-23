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
    this.balance = map['rewards'];
    this.lock = map['lock'] ?? '0';
    this.pledge = map['pledge'] ?? "0";
    this.available = map['available'] ?? "0";
    this.qualityPower = map['quality_adj_power'];
    this.rewards = map['rewards'];
    this.deposit = map['deposit'];
    this.rawPower = map['power'];
    this.percent = map['power_percent'];
    this.rank = map['rank'];
    this.blockCount = map['block_count'];
    this.sectorSize = map['sector_size'];
    this.allSectors = map['sector_count'];
    this.liveSectors = map['active_sector_count'];
    this.faultSectors = map['fault_sector_count'];
    this.preCommitSectors = map['recover_sector_count'];
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
    address = map['address'];
    type = map['type'];
    balance = map['balance'];
    time = map['estimate_valid_time'];
    yestodayGasFee = map['yesterday_cost'];
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
    total = json['total_balance'];
    available = json['available_balance'];
    locked = json['locked_funds'];
    pledge = json['initial_pledge'];
  }
}
