// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

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
      methodName: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StoreMessage obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.methodName);
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
      msigSuccess: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoreMultiMessage obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.methodName);
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
