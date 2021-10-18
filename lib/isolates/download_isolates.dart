part of cpp_native;


void _download(SendPort firstPort) {
  try {
    ReceivePort isolateRecievePort = ReceivePort();
    firstPort.send(isolateRecievePort.sendPort);
    isolateRecievePort.listen((message) async {
      if (message is DownloadOption) {
        var response =
            await _getDownloadInfo(message.bearerToken, message.recordID);
        if (response == null) {
          throw Exception('Can\'t get downloadsDir');
        }
        final channel = IOWebSocketChannel.connect('ws://95.216.228.24:4040');
        // final channel = IOWebSocketChannel.connect('ws://localhost:4040');

        //print(String.fromCharCodes(message));
        List<String> queries = [];
        response.downloadDirs?.forEach((element) {
          var query = {
            '"token"': '"${element.downloadTransactionToken}"',
            '"session"': '"${element.session}"',
            '"download"': true,
            '"StartRequest"': true
          };
          queries.add(query.toString());

          print(jsonEncode(query));
          // channel.sink.add(query.toString());
          // channel.stream.listen((event) {
          //   if (event is String) {
          //     var response = json.decode(event);
          //     element.proxyIp = response['ip'] as String;
          //     element.proxyPort = response['port'] as int;
          //     channel.sink.close();
          //   }
          // });
        });
        int iter = 0;
        channel.sink.add(queries.first);
        channel.stream.listen((event) {
          if (event is String) {
            var jsonFromProxy = json.decode(event);
            response.downloadDirs?[iter].proxyIp =
                jsonFromProxy['ip'] as String;
            response.downloadDirs?[iter].proxyPort =
                jsonFromProxy['port'] as int;

            iter++;
            if (iter < queries.length) {
              channel.sink.add(queries[iter]);
            } else {
              channel.sink.close();
            }
          }
        }).onDone(() {
          DownloadIsolateController controller = DownloadIsolateController(
              responce: response,
              firstPort: firstPort,
              pathToDir: message.pathToDir.path,
              onDone: (parts) async {
                File downloadedFile = await _assemblyFile(
                  recordID: response.id!,
                  originalFilename: response.name!,
                  pathToDir: message.pathToDir.path,
                  response: response,
                  downloadPartIsolateList: parts,
                );
                firstPort.send(downloadedFile);
              });
          controller.manageIsolate();
        });
      }
    });
  } catch (e) {
    print(e);
    return;
  }
}

Future<DownloadResponse?> _getDownloadInfo(
    String bearerToken, String recordID) async {
  try {
    var _dio =
        Dio(BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
    var response = await _dio.get(
      '/record/$recordID/download',
      options: Options(
        headers: {'Authorization': ' Bearer $bearerToken'},
      ),
    );
    var downloadResponse = DownloadResponse.fromJson(response.data);
    return downloadResponse;
  } catch (e) {
    print(e);
    try {
      var _dio = Dio(
          BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
      var response = await _dio.get(
        '/record/$recordID/download',
        options: Options(
          headers: {'Authorization': ' Bearer $bearerToken'},
        ),
      );
      var downloadResponse = DownloadResponse.fromJson(response.data);
      return downloadResponse;
    } catch (e) {
      print(e);

      return null;
    }
  }
}

void _downloadPart(SendPort sendPort) async {
  ReceivePort isolateRecievePort = ReceivePort();
  sendPort.send(isolateRecievePort.sendPort);
  RSAPrivateKey? privKey;

  isolateRecievePort.listen((message) async {
    try {
      if (message is RSAPrivateKey) {
        privKey = message;
      }
      if (message is DownloadDir) {
        IOWebSocketChannel channel = IOWebSocketChannel.connect(
            'ws://${message.proxyIp}:${message.proxyPort}');
        // 'ws://${message.proxyIp}:${message.proxyPort}');
        var query = {
          '"Transaction token"': '"${message.downloadTransactionToken}"',
          '"Init"': true,
        };
        channel.sink.add(query.toString());
        channel.stream.listen((socketMessage) async {
          if (socketMessage is String) {
            Map<String, dynamic> decodeJson = json.decode(socketMessage);
            if (decodeJson['Ready_for_send'] == 'Ready_for_send') {
              query = {'"filename"': '"${message.uploadTransactionToken}"'};
              channel.sink.add(query.toString());
            }
            if (decodeJson.containsKey('result') &&
                decodeJson['result'] == 'File doesn\'t exists') {
              print('This keeper has no file');
            }
          }
          if (socketMessage is Uint8List) {
            final algorithm = Sha1();
            var hash = await algorithm.hash(socketMessage);
            String stringHash = hash.bytes.toString();
            print(stringHash);
            print(message.hash);
            if (message.hash == stringHash) {
              print('Transmission OK');
              developer.log('Transmission OK');
              Uint8List decryptedFile = rsaDecrypt(privKey!, socketMessage);
              FilePartInfo downloadedFile = FilePartInfo(
                  decryptedPartFile: decryptedFile,
                  uploadTransactionToken: message.uploadTransactionToken!);
              channel.sink.close();
              sendPort.send(downloadedFile);
            } else {
              print('Hashes doesn\'t match');
              channel.sink.close();
            }
          }

          if (socketMessage == 'File doesn\'t exists') {
            throw Exception(socketMessage);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  });
}

Future<File> _assemblyFile({
  required String recordID,
  required List<DownloadPartIsolate> downloadPartIsolateList,
  required String pathToDir,
  required String originalFilename,
  required DownloadResponse response,
}) async {
  File decryptedFile = File(pathToDir + '/' + originalFilename);
  decryptedFile.createSync();
  List<int> decodedFile = [];
  response.downloadDirs?.forEach((element) {
    var encodedFile = (downloadPartIsolateList.firstWhere((downloadElement) =>
        element.uploadTransactionToken ==
        downloadElement.uploadTransactionToken)).filePart;
    decodedFile.addAll(encodedFile!);
  });
  decryptedFile.writeAsBytesSync(decodedFile);
  return decryptedFile;
}

class DownloadIsolateController {
  DownloadResponse responce;
  SendPort firstPort;
  int availableIsolates = 0;
  List<DownloadPartIsolate> parts = [];
  Function(List<DownloadPartIsolate>) onDone;
  final String pathToDir;

  DownloadIsolateController({
    required this.firstPort,
    required this.responce,
    required this.onDone,
    required this.pathToDir,
  });

  void manageIsolate() async {
    responce.downloadDirs!.forEach((element) {
      DownloadPartIsolate downloadPartIsolate = DownloadPartIsolate(
          uploadTransactionToken: element.uploadTransactionToken!);
      parts.add(downloadPartIsolate);
    });

    Database.path = pathToDir;
    Database db = await Database.getInstanse();
    var fileInfo = await db.readData(responce.id!);
    RSAPrivateKey? privKey =
        parsePrivateKeyFromPem((fileInfo as DBFileInfo).privateKey);
    fileInfo = null;

    int numOfActualThreads = 1;
    if (numOfThreads > parts.length) {
      numOfActualThreads = parts.length;
    } else {
      numOfActualThreads = numOfThreads;
    }
    for (int i = 0; i < numOfActualThreads; i++) {
      // for (int i = 0; i < numOfThreads; i++) {
      availableIsolates++;
      SendPort? sendPort;
      ReceivePort port = ReceivePort();
      Isolate isolate = await Isolate.spawn(_downloadPart, port.sendPort);

      port.listen((message) {
        if (message is SendPort) {
          message.send(privKey);
          sendPort = message;
          parts[i].state = FileSendState.inProgress;
          print('index of recieving part = $i');
          message.send(responce
              .downloadDirs![i]); // Добавить выбор валидной для загрузки части
        }
        if (message is FilePartInfo) {
          int index = parts.indexWhere((element) =>
              element.uploadTransactionToken == message.uploadTransactionToken);
          parts[index].filePart = message.decryptedPartFile;
          parts[index].state = FileSendState.sended;
          try {
            var part = parts.firstWhere(
                (element) => element.state == FileSendState.available);

            print('index of recieving part = ${parts.indexOf(part)}');
            parts[parts.indexOf(part)].state = FileSendState.inProgress;
            sendPort!.send(responce.downloadDirs![parts.indexOf(part)]);
          } catch (e) {
            print(e);
            availableIsolates--;
            isolate.kill();
            port.close();
            if (availableIsolates == 0) {
              onDone(parts);
            }
          }
        }
      });
    }
  }
}

class FilePartInfo {
  final String uploadTransactionToken;
  final Uint8List decryptedPartFile;
  FilePartInfo({
    required this.uploadTransactionToken,
    required this.decryptedPartFile,
  });
}
