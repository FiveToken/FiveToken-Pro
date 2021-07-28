// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonitorAddressAdapter extends TypeAdapter<MonitorAddress> {
  @override
  final int typeId = 6;

  @override
  MonitorAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonitorAddress(
      label: fields[0] as String,
      cid: fields[1] as String,
      threshold: fields[2] as String,
      type: fields[3] as String,
    )..miner = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, MonitorAddress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.cid)
      ..writeByte(2)
      ..write(obj.threshold)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.miner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitorAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
