import 'dart:io';

import 'package:hive/hive.dart';

import 'database_models.dart';

class Database {
  static const _boxName = 'database';
  static Database? _db;
  late Box _box;
  static late String path;

  static Future<Database> getInstanse() async {
    if (_db == null) {
      //var path = Directory.current.path;

      // await Hive.initFlutter(path);
      Hive.init(path);
      Hive.registerAdapter(DBFileInfoAdapter());
      Hive.registerAdapter(PartStateAdapter());
      Hive.registerAdapter(DbPartAdapter());
      Box box = await Hive.openBox(_boxName);
      _db = Database._init(box);
    }

    return _db!;
  }

  // Future<void> initDatabase() async {
  //   var path = Directory.current.path;

  //   // await Hive.initFlutter(path);
  //   Hive.init(path);
  //   Hive.registerAdapter(DBFileInfoAdapter());
  //   Hive.registerAdapter(PartStateAdapter());
  //   Hive.registerAdapter(DbPartAdapter());
  //   _box = await Hive.openBox(_boxName);
  //   // var file = File(filename: 'test.txt', fullHash: 'someHash', size: 10);
  //   //  await box.put('file1', file);
  //   //  print((box.get('file1') as File).size);
  // }

  Database._init(this._box);

  Future<void> writeData(String key, dynamic data) async {
    await _box.put(key, data);
  }

  dynamic readData(String key) async {
    return await _box.get(key);
  }

  void test() {
    _box.toMap().forEach((key, value) {
      print('key: $key, value: ${value.toString()}');
    });
  }

  void closeDatabase() async {
    if (Hive.isBoxOpen(_box.name)) {
      await _box.close();
      await Hive.close();
    }
  }
}
