// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MinerMetaAdapter extends TypeAdapter<MinerMeta> {
  @override
  final int typeId = 9;

  @override
  MinerMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerMeta(
      balance: fields[0] as String,
      lock: fields[1] as String,
      pledge: fields[2] as String,
      available: fields[4] as String,
      qualityPower: fields[5] as String,
      rewards: fields[6] as String,
      deposit: fields[3] as String,
      rawPower: fields[7] as String,
      percent: fields[8] as String,
      blockCount: fields[10] as num,
      sectorSize: fields[11] as num,
      allSectors: fields[12] as num,
      rank: fields[9] as num,
      liveSectors: fields[13] as num,
      faultSectors: fields[14] as num,
      preCommitSectors: fields[15] as num,
    );
  }

  @override
  void write(BinaryWriter writer, MinerMeta obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.balance)
      ..writeByte(1)
      ..write(obj.lock)
      ..writeByte(2)
      ..write(obj.pledge)
      ..writeByte(3)
      ..write(obj.deposit)
      ..writeByte(4)
      ..write(obj.available)
      ..writeByte(5)
      ..write(obj.qualityPower)
      ..writeByte(6)
      ..write(obj.rewards)
      ..writeByte(7)
      ..write(obj.rawPower)
      ..writeByte(8)
      ..write(obj.percent)
      ..writeByte(9)
      ..write(obj.rank)
      ..writeByte(10)
      ..write(obj.blockCount)
      ..writeByte(11)
      ..write(obj.sectorSize)
      ..writeByte(12)
      ..write(obj.allSectors)
      ..writeByte(13)
      ..write(obj.liveSectors)
      ..writeByte(14)
      ..write(obj.faultSectors)
      ..writeByte(15)
      ..write(obj.preCommitSectors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MinerAddressAdapter extends TypeAdapter<MinerAddress> {
  @override
  final int typeId = 10;

  @override
  MinerAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerAddress(
      address: fields[0] as String,
      type: fields[1] as String,
      balance: fields[2] as String,
      time: fields[3] as int,
    )..yestodayGasFee = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, MinerAddress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.yestodayGasFee);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MinerHistoricalStatsAdapter extends TypeAdapter<MinerHistoricalStats> {
  @override
  final int typeId = 11;

  @override
  MinerHistoricalStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerHistoricalStats(
      block: fields[0] as String,
      total: fields[1] as String,
      worker: fields[2] as String,
      controller: fields[3] as String,
      sector: fields[4] as String,
      profitPerTib: fields[6] as String,
      gasFee: fields[7] as String,
      lucky: fields[8] as String,
      pledge: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MinerHistoricalStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.block)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.worker)
      ..writeByte(3)
      ..write(obj.controller)
      ..writeByte(4)
      ..write(obj.sector)
      ..writeByte(5)
      ..write(obj.pledge)
      ..writeByte(6)
      ..write(obj.profitPerTib)
      ..writeByte(7)
      ..write(obj.gasFee)
      ..writeByte(8)
      ..write(obj.lucky);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerHistoricalStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MinerStatsAdapter extends TypeAdapter<MinerStats> {
  @override
  final int typeId = 12;

  @override
  MinerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerStats(
      historicalStats: fields[0] as MinerHistoricalStats,
      addressList: (fields[1] as List)?.cast<MinerAddress>(),
      owner: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MinerStats obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.historicalStats)
      ..writeByte(1)
      ..write(obj.addressList)
      ..writeByte(2)
      ..write(obj.owner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MinerInfoAdapter extends TypeAdapter<MinerInfo> {
  @override
  final int typeId = 13;

  @override
  MinerInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerInfo(
      meta: fields[0] as MinerMeta,
      stats: fields[1] as MinerStats,
    );
  }

  @override
  void write(BinaryWriter writer, MinerInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.meta)
      ..writeByte(1)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
