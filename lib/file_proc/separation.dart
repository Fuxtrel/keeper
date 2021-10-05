import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

const MB = (1024 * 1024);

class Separation {
  String file_path;
  int parts_count = 0;
  int part_size = 0;
  List<Uint8List> data = [];
  List<List<Uint8List>> fileParts = [];

  Separation({required this.file_path});

  void readFile() {
    final file = File(file_path);
    final data = file.readAsBytesSync();
  }

  void partsCount() {
    final file = File(file_path);
    if (file.lengthSync() <= 1 * MB) {
      parts_count = 3;
    } else if ((file.lengthSync() > 1 * MB) && (file.lengthSync() <= 10 * MB)) {
      parts_count = 7;
    } else if (file.lengthSync() > 10 * MB) {
      parts_count = (file.lengthSync() % MB == 0)
          ? (file.lengthSync() ~/ MB)
          : ((file.lengthSync() ~/ MB) + 1);
    }
  }

  void separateFile() {
    final file = File(file_path);
    readFile();
    for (int j = 0; j < parts_count - 1; j++) {
      var list = new List.filled(part_size, Uint8List(0), growable: false);
      for (int i = 0; i < file.lengthSync() ~/ part_size; i++) {
        list[i] = data[j * part_size + i];
      }
      fileParts.add(list);
    }
    var list = new List.filled(part_size, Uint8List(0), growable: false);
    for (int i = 0;
        i < (file.lengthSync() ~/ part_size) + (file.lengthSync() % part_size);
        i++) {
      list[i] = data[file.lengthSync() -
          (file.lengthSync() ~/ part_size) +
          (file.lengthSync() % part_size) -
          1];
    }
    fileParts.add(list);
  }
}
