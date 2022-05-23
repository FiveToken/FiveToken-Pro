// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 3;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      count: fields[0] as int,
      ck: fields[4] as String,
      label: fields[3] as String,
      address: fields[5] as String,
      type: fields[6] as String,
      readonly: fields[1] as int,
      walletType: fields[2] as int,
      balance: fields[8] as String,
      owner: fields[7] as String,
      push: fields[10] as bool,
      inAddressBook: fields[9] as bool,
      mne: fields[12] as String,
      skKek: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.count)
      ..writeByte(1)
      ..write(obj.readonly)
      ..writeByte(2)
      ..write(obj.walletType)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.ck)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.owner)
      ..writeByte(8)
      ..write(obj.balance)
      ..writeByte(9)
      ..write(obj.inAddressBook)
      ..writeByte(10)
      ..write(obj.push)
      ..writeByte(11)
      ..write(obj.skKek)
      ..writeByte(12)
      ..write(obj.mne);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MultiSignWalletAdapter extends TypeAdapter<MultiSignWallet> {
  @override
  final int typeId = 14;

  @override
  MultiSignWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultiSignWallet(
      label: fields[0] as String,
      id: fields[1] as String,
      owner: fields[2] as String,
      balance: fields[3] as String,
      threshold: fields[4] as int,
      cid: fields[6] as String,
      blockTime: fields[8] as num,
      status: fields[7] as int,
      signerMap: (fields[9] as Map)?.cast<String, String>(),
      robustAddress: fields[10] as String,
      signers: (fields[5] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MultiSignWallet obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.owner)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.threshold)
      ..writeByte(5)
      ..write(obj.signers)
      ..writeByte(6)
      ..write(obj.cid)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.blockTime)
      ..writeByte(9)
      ..write(obj.signerMap)
      ..writeByte(10)
      ..write(obj.robustAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiSignWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
