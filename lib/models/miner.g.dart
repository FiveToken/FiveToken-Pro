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
      label: fields[6] as String,
      miner: fields[5] as String,
      yestodayGasFee: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MinerAddress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.yestodayGasFee)
      ..writeByte(5)
      ..write(obj.miner)
      ..writeByte(6)
      ..write(obj.label);
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

class MinerSelfBalanceAdapter extends TypeAdapter<MinerSelfBalance> {
  @override
  final int typeId = 19;

  @override
  MinerSelfBalance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinerSelfBalance(
      total: fields[0] as String,
      available: fields[1] as String,
      locked: fields[2] as String,
      pledge: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MinerSelfBalance obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.available)
      ..writeByte(2)
      ..write(obj.locked)
      ..writeByte(3)
      ..write(obj.pledge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinerSelfBalanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
