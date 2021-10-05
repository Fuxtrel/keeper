// GENERATED CODE - DO NOT MODIFY BY HAND

part of models;

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartStateAdapter extends TypeAdapter<PartState> {
  @override
  final int typeId = 3;

  @override
  PartState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PartState.sended;
      case 1:
        return PartState.encrypted;
      case 2:
        return PartState.notSended;
      case 3:
        return PartState.notEncrypted;
      default:
        return PartState.sended;
    }
  }

  @override
  void write(BinaryWriter writer, PartState obj) {
    switch (obj) {
      case PartState.sended:
        writer.writeByte(0);
        break;
      case PartState.encrypted:
        writer.writeByte(1);
        break;
      case PartState.notSended:
        writer.writeByte(2);
        break;
      case PartState.notEncrypted:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DBFileInfoAdapter extends TypeAdapter<DBFileInfo> {
  @override
  final int typeId = 1;

  @override
  DBFileInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DBFileInfo(
      filename: fields[0] as String,
      fullHash: fields[2] as String,
      size: fields[1] as int,
      parts: (fields[3] as List).cast<DbPart>(),
      recordID: fields[4] as String,
      privateKey: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DBFileInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.filename)
      ..writeByte(1)
      ..write(obj.size)
      ..writeByte(2)
      ..write(obj.fullHash)
      ..writeByte(3)
      ..write(obj.parts)
      ..writeByte(4)
      ..write(obj.recordID)
      ..writeByte(5)
      ..write(obj.privateKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBFileInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbPartAdapter extends TypeAdapter<DbPart> {
  @override
  final int typeId = 2;

  @override
  DbPart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbPart(
      keeperID: fields[0] as String,
      partHash: fields[2] as String,
      sessionID: fields[1] as String,
      state: fields[3] as PartState,
      transactionToken: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DbPart obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.keeperID)
      ..writeByte(1)
      ..write(obj.sessionID)
      ..writeByte(2)
      ..write(obj.partHash)
      ..writeByte(3)
      ..write(obj.state)
      ..writeByte(4)
      ..write(obj.transactionToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbPartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
