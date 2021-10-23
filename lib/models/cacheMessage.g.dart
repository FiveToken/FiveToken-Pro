// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cacheMessage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreMessageAdapter extends TypeAdapter<StoreMessage> {
  @override
  final int typeId = 4;

  @override
  StoreMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreMessage(
      from: fields[0] as String,
      to: fields[1] as String,
      signedCid: fields[3] as String,
      value: fields[4] as String,
      blockTime: fields[5] as num,
      owner: fields[2] as String,
      pending: fields[7] as num,
      args: fields[8] as String,
      type: fields[9] as String,
      multiParams: fields[10] as String,
      nonce: fields[11] as num,
      exitCode: fields[6] as num,
      multiMethod: fields[14] as String,
      methodName: fields[12] as String,
    )..mid = fields[13] as String;
  }

  @override
  void write(BinaryWriter writer, StoreMessage obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.owner)
      ..writeByte(3)
      ..write(obj.signedCid)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.blockTime)
      ..writeByte(6)
      ..write(obj.exitCode)
      ..writeByte(7)
      ..write(obj.pending)
      ..writeByte(8)
      ..write(obj.args)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.multiParams)
      ..writeByte(11)
      ..write(obj.nonce)
      ..writeByte(12)
      ..write(obj.methodName)
      ..writeByte(13)
      ..write(obj.mid)
      ..writeByte(14)
      ..write(obj.multiMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreMultiMessageAdapter extends TypeAdapter<StoreMultiMessage> {
  @override
  final int typeId = 15;

  @override
  StoreMultiMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreMultiMessage(
      from: fields[0] as String,
      to: fields[1] as String,
      signedCid: fields[3] as String,
      value: fields[4] as String,
      blockTime: fields[5] as num,
      owner: fields[2] as String,
      pending: fields[7] as num,
      type: fields[8] as String,
      exitCode: fields[6] as num,
      msigTo: fields[9] as String,
      msigValue: fields[10] as String,
      txnId: fields[11] as String,
      msigRequired: fields[12] as num,
      msigApproved: fields[13] as num,
      proposalCid: fields[15] as String,
      methodName: fields[16] as String,
      nonce: fields[17] as int,
      msigSuccess: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoreMultiMessage obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.owner)
      ..writeByte(3)
      ..write(obj.signedCid)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.blockTime)
      ..writeByte(6)
      ..write(obj.exitCode)
      ..writeByte(7)
      ..write(obj.pending)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.msigTo)
      ..writeByte(10)
      ..write(obj.msigValue)
      ..writeByte(11)
      ..write(obj.txnId)
      ..writeByte(12)
      ..write(obj.msigRequired)
      ..writeByte(13)
      ..write(obj.msigApproved)
      ..writeByte(14)
      ..write(obj.msigSuccess)
      ..writeByte(15)
      ..write(obj.proposalCid)
      ..writeByte(16)
      ..write(obj.methodName)
      ..writeByte(17)
      ..write(obj.nonce);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreMultiMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CacheMultiMessageAdapter extends TypeAdapter<CacheMultiMessage> {
  @override
  final int typeId = 17;

  @override
  CacheMultiMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheMultiMessage(
      cid: fields[0] as String,
      blockTime: fields[1] as num,
      from: fields[2] as String,
      to: fields[3] as String,
      status: fields[4] as String,
      fee: fields[5] as String,
      method: fields[7] as String,
      innerParams: fields[8] as String,
      nonce: fields[9] as int,
      owner: fields[10] as String,
      params: fields[6] as String,
      mid: fields[11] as String,
      pending: fields[12] as int,
      txId: fields[14] as int,
      value: fields[16] as String,
      approves: (fields[17] as List)?.cast<MultiApproveMessage>(),
      type: fields[15] as int,
      exitCode: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CacheMultiMessage obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.cid)
      ..writeByte(1)
      ..write(obj.blockTime)
      ..writeByte(2)
      ..write(obj.from)
      ..writeByte(3)
      ..write(obj.to)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.fee)
      ..writeByte(6)
      ..write(obj.params)
      ..writeByte(7)
      ..write(obj.method)
      ..writeByte(8)
      ..write(obj.innerParams)
      ..writeByte(9)
      ..write(obj.nonce)
      ..writeByte(10)
      ..write(obj.owner)
      ..writeByte(11)
      ..write(obj.mid)
      ..writeByte(12)
      ..write(obj.pending)
      ..writeByte(13)
      ..write(obj.exitCode)
      ..writeByte(14)
      ..write(obj.txId)
      ..writeByte(15)
      ..write(obj.type)
      ..writeByte(16)
      ..write(obj.value)
      ..writeByte(17)
      ..write(obj.approves);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMultiMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MultiApproveMessageAdapter extends TypeAdapter<MultiApproveMessage> {
  @override
  final int typeId = 18;

  @override
  MultiApproveMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultiApproveMessage(
      from: fields[0] as String,
      fee: fields[1] as String,
      time: fields[2] as num,
      nonce: fields[3] as int,
      exitCode: fields[4] as int,
      proposeCid: fields[6] as String,
      cid: fields[7] as String,
      txId: fields[8] as int,
      pending: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MultiApproveMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.fee)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.nonce)
      ..writeByte(4)
      ..write(obj.exitCode)
      ..writeByte(5)
      ..write(obj.pending)
      ..writeByte(6)
      ..write(obj.proposeCid)
      ..writeByte(7)
      ..write(obj.cid)
      ..writeByte(8)
      ..write(obj.txId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiApproveMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
