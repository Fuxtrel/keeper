library models;

import 'package:hive/hive.dart';
import "package:pointycastle/export.dart";

part 'database_models.g.dart';

@HiveType(typeId: 1)
class DBFileInfo {
  @HiveField(0)
  String filename;

  @HiveField(1)
  int size;

  @HiveField(2)
  String fullHash;

  @HiveField(3)
  List<DbPart> parts;

  @HiveField(4)
  String recordID;

  @HiveField(5)
  String? privateKey;

  DBFileInfo({
    required this.filename,
    this.fullHash = '',
    required this.size,
    this.parts = const [],
    required this.recordID,
    this.privateKey,
  });

  DBFileInfo copyWith(
    DbPart? part,
    String? key,
  ) {
    return DBFileInfo(
      filename: filename,
      size: size,
      fullHash: fullHash,
      parts: part == null ? [...parts, part!] : parts,
      recordID: recordID,
      privateKey: key ?? this.privateKey,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    String partsStr = '';
    parts.forEach((element) {
      partsStr +=
          '${element.keeperID}, ${element.partHash}, ${element.sessionID}, ${element.state.toString()}';
    });
    return '$filename, $fullHash, $partsStr';
  }
}

@HiveType(typeId: 2)
class DbPart {
  @HiveField(0)
  String keeperID;

  @HiveField(1)
  String sessionID;

  @HiveField(2)
  String partHash;

  @HiveField(3)
  PartState state;

  @HiveField(4)
  String transactionToken;

  DbPart({
    this.keeperID = '',
    this.partHash = '',
    required this.sessionID,
    required this.state,
    required this.transactionToken,
  });
}

@HiveType(typeId: 3)
enum PartState {
  @HiveField(0)
  sended,

  @HiveField(1)
  encrypted,

  @HiveField(2)
  notSended,

  @HiveField(3)
  notEncrypted,
}
