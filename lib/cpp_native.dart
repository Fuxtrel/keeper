library cpp_native;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:keeper/file_tipification/file_typification.dart';
import 'package:keeper/database/database.dart';
import 'package:keeper/database/database_models.dart';
import 'package:keeper/file_proc/encryption.dart';
import 'package:keeper/models/download_dir.dart';
import 'package:keeper/models/download_response.dart';
import 'package:keeper/models/record_responce.dart';
import 'package:keeper/models/part.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';
import 'package:web_socket_channel/io.dart';
import "package:pointycastle/export.dart";
import 'package:cryptography/cryptography.dart';
import 'json_root/json_root.dart';


part 'isolates/send_isolates.dart';
part 'models.dart';
part 'isolates/recieve_isolates.dart';
part 'isolates/download_isolates.dart';

class CppNative {
  /*static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }*/

  Isolate? sendIsolate;
  ReceivePort? sendRecievePort;

  Future<String?> send(
      {required String filePath,
      required Function(String) callback,
      required String bearerToken,
      String? foldeId}) async {
    sendRecievePort = ReceivePort();
    sendIsolate = await Isolate.spawn(_send, sendRecievePort!.sendPort);

    sendRecievePort?.listen((message) async {
      if (message is String) {
        callback(message);
        // Database db = await Database.getInstanse();
        // await db.initDatabase();
        //db.test();
        _closeIsolate(sendIsolate, sendRecievePort);
      }
      if (message is SendPort) {
        var documentsFolder = '../files';

        var data = SendData(
            documentsFolderPath: documentsFolder,
            filePath: filePath,
            bearerToken: bearerToken,
            folderId: foldeId);

        message.send(data);
      }
    });
  }

  Future<void> receiver(String keeperId, String token) async {
    var documentsFolder = '../files';
    var receivePort = ReceivePort();
    Isolate receiver = await Isolate.spawn(_receive, receivePort.sendPort);
    SendPort? sendPort;
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
        sendPort?.send([documentsFolder, keeperId, token]);
      } else if (message is bool) {
        if (!message) {
          sendPort?.send([documentsFolder, keeperId, token]);
        }
      }
    });

  }

  _closeIsolate(Isolate? isolate, ReceivePort? port) {
    isolate?.kill(priority: Isolate.immediate);
    port?.close();
  }

  Future<void> downloadFile(
      {required String recordID,
      required String bearerToken,
      required Function(File) callback}) async {
    var documentsFolder = '../files';
    ReceivePort port = ReceivePort();
    Isolate isolate = await Isolate.spawn(_download, port.sendPort);
    DownloadOption options = DownloadOption(
      bearerToken: bearerToken,
      recordID: recordID,
      pathToDir: Directory('../files'),
    );

    port.listen((message) {
      if (message is SendPort) {
        message.send(options);
      }
      if (message is File) {
        callback(message);
        _closeIsolate(isolate, port);
      }
    });
  }
}
