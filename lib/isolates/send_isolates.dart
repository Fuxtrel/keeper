part of cpp_native;





const int MB = 15 * (1024 * 1024);
const int MAXSIZE = 15 * 100 * 1024 * 1024;
const int MINSIZE = 50 * 1024;
const int MAXPART = 100;
const int MINPART = 5;

void _send(SendPort firstSendPort) {
  ReceivePort isolateRecievePort = ReceivePort();
  firstSendPort.send(isolateRecievePort.sendPort);

  isolateRecievePort.listen((sendMessage) async {
    if (sendMessage is SendData) {
      File file = File(sendMessage.filePath);
      DBFileInfo fileInfo = DBFileInfo(
          filename: file.path.split('/').last,
          size: file.statSync().size,
          recordID: '0');
      Database.path = sendMessage.documentsFolderPath;
      Database db = await Database.getInstanse();

      try {
        var pair = generateRSAkeyPair(exampleSecureRandom());
        var fRecordResponce = _createRecord(file, sendMessage.bearerToken,
            sendMessage.folderId, sendMessage.documentsFolderPath);
        List<Uint8List> parts = [];
        var fParts = _splitFile(file: file, fileInfo: fileInfo);
        RecordResponce? recordResponse;

        fParts.then((value) => parts = value);
        fRecordResponce.then((value) {
          if (value == null) {
            throw Exception('Error while create record');
          } else {
            recordResponse = value;
          }
        });
        // fileInfo.recordID = recordResponse!.id!;
        Future.wait([fRecordResponce, fParts]).whenComplete(() async {
          final channel = IOWebSocketChannel.connect('ws://95.216.228.24:4040');
          fileInfo.recordID = recordResponse!.id!;
          // var hash = await algorithm.hash(file);
          List<String> queries = [];
          int iterX = 0;
          int iterY = 0;
          recordResponse?.parts?.forEach((element) {
            element.locations?.forEach((location) {
              var query = {
                '"token"': '"${location.transactionToken}"',
                '"session"': '"${location.session}"',
                '"download"': false,
                '"StartRequest"': true
              };
              queries.add(query.toString());
              print(jsonEncode(query));
            });
          });
          // print('Added queries');

          int? maxLocations = recordResponse?.parts?.first.locations!.length;
          int? maxParts = recordResponse?.parts?.length;
          channel.sink.add(queries.first);

          channel.stream.listen((event) {
            if (event is String) {
              Map<String, dynamic> response = json.decode(event);
              if (response.containsKey("keeper_state_online")) {
                throw Exception('keeper_state_online: false');
              } else {
                // String transactionToken = response['transaction token'];

                recordResponse?.parts?[iterY].locations![iterX].proxyIp =
                    response['ip'] as String;
                recordResponse?.parts?[iterY].locations![iterX].proxyPort =
                    response['port'] as int;
                if (iterX < maxLocations! - 1) {
                  iterX++;
                  channel.sink.add(queries[iterY * maxLocations + iterX]);
                } else {
                  iterX = 0;
                  iterY++;
                  if (iterY != maxParts) {
                    channel.sink.add(queries[iterY * maxLocations + iterX]);
                  } else {
                    channel.sink.close();
                  }
                }
              }
            }
          }).onDone(() {
            List<SendPartInfoWithState> partsInfo = [];
            parts.forEach((element) {
              SendPartInfo sendInfo = SendPartInfo(
                  partFile: element,
                  publicKey: pair.publicKey,
                  storeds: recordResponse!.parts![parts.indexOf(element)],
                  privateKey: pair.privateKey,
                  index: parts.indexOf(element),
                  bearerToken: sendMessage.bearerToken);
              partsInfo.add(SendPartInfoWithState(info: sendInfo));
            });
            SendPartIsolateController controller = SendPartIsolateController(
                fileInfo: fileInfo,
                pair: pair,
                parts: partsInfo,
                recordResponce: recordResponse!,
                sendMessage: sendMessage,
                writeToDB: (infoToDB) async {
                  await db.writeData(fileInfo.recordID, infoToDB);
                  print('Data written to DataBase');
                  firstSendPort.send('done');
                });
            controller.manageIsolate();
          });
        });

        //location.proxyIp = response['ip'] as String;
        //location.proxyPort = response['port'] as int;

        //part = null;
        //print(parts.first.toString());

      } catch (e) {
        print(e);
        db.writeData(fileInfo.recordID, fileInfo);
        firstSendPort.send('Failed with exception $e');
      }
    }
  });
}

Future<String?> getMediaId(String bearerToken) async {
  try {
    var response = await Dio()
        .get('https://upstorage.net/api/tenant/608c0906cb5fb91ccf8bf5a5/root',
            options: Options(headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $bearerToken',
            }));
    var json = JsonRoot.fromJson(response.data);
    var folders = json.folders;
    return folders!.firstWhere((element) => element.name == 'Media').id;
  } catch (e) {
    print(e);
  }
}

Future<String?> getFotoVideoId(String bearerToken, String name) async {
  try {
    String? parentFolderId = await getMediaId(bearerToken);
    if (parentFolderId == null) {
      throw Exception("Dont got parentFolderId");
    } else {
      var response = await Dio().get(
          'https://upstorage.net/api/tenant/608c0906cb5fb91ccf8bf5a5/folder/$parentFolderId',
          options: Options(headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          }));
      var json = JsonRoot.fromJson(response.data);
      return json.folders!.firstWhere((element) => element.name == name).id;
    }
  } catch (e) {
    print(e);
  }
}

Future<List<Uint8List>> _splitFile(
    {required File file, required DBFileInfo fileInfo}) async {
  int numOfParts = _numOfParts(file);
  Uint8List? part = file.readAsBytesSync();
  int partSize = part.length / numOfParts ~/ 1;
  Sha1? algorithm = Sha1();
  algorithm.hash(part).then((value) => fileInfo.fullHash = value.toString());
  algorithm = null;
  List<Uint8List> parts = [];
  if (numOfParts == 1) {
    parts.add(part);
  } else {
    int lastIndex = 0;
    for (int i = 0; i < numOfParts; i++) {
      if (i == numOfParts - 1) {
        parts.add(part.sublist(lastIndex));
      } else {
        parts.add(part.sublist(lastIndex, lastIndex + partSize));
        lastIndex += partSize;
      }
    }
  }
  return parts;
}

int _numOfParts(File file) {
  int size = file.statSync().size;
  if (size < MINSIZE) {
    return MINPART;
  } else if (size > MAXSIZE) {
    var res = size / MB;
    if (res is int) {
      return res as int;
    } else {
      return res ~/ 1 + 1;
    }
  }
  double base = log(MAXSIZE - MINSIZE) / log(MAXPART - MINPART);
  var numOfParts = pow(size - MINSIZE, 1 / base);

  if (numOfParts is int) {
    return numOfParts;
  } else {
    return numOfParts ~/ 1 + 1;
  }
}

Future<String?> uploadProfilePic(
    {required File file,
    required String bearer_token,
    required String documentsFolderPath}) async {
  try {
    Image? image;
    switch (SortByExtension().extractExtension(file.path.split('/').last)) {
      case 'jpg':
        image = copyResize(decodeJpg(file.readAsBytesSync()),
            width: 124, height: 124);
        File(documentsFolderPath + '/thumbnail_${file.path.split('/').last}')
            .writeAsBytesSync(encodeJpg(image));
        break;
      case 'png':
        image = copyResize(decodePng(file.readAsBytesSync())!,
            width: 124, height: 124);
        File(documentsFolderPath + '/thumbnail_${file.path.split('/').last}')
            .writeAsBytesSync(encodePng(image));
        break;
      case 'jpeg':
        image = copyResize(decodeJpg(file.readAsBytesSync()),
            width: 124, height: 124);
        File(documentsFolderPath + '/thumbnail_${file.path.split('/').last}')
            .writeAsBytesSync(encodeJpg(image));
        break;
      case 'gif':
        image = copyResize(decodeGif(file.readAsBytesSync())!,
            width: 124, height: 124);
        File(documentsFolderPath + '/thumbnail_${file.path.split('/').last}')
            .writeAsBytesSync(encodeGif(image));
        break;
    }

    String path = '/file';
    path +=
        '/credentials?filename=${file.path.split('/').last}&storageId=recordThumbnail';
    final resFileCreate = await Dio(BaseOptions(
            baseUrl:
                'https://upstorage.net/api/tenant/608c0906cb5fb91ccf8bf5a5'))
        .get(
      path,
      options: Options(headers: {'Authorization': ' Bearer $bearer_token'}),
    );
    if (resFileCreate.statusCode == 200) {
      var uploadUrl = resFileCreate.data['uploadCredentials']['url'];
      FormData formData = new FormData.fromMap({
        "filename": file.path.split('/').last,
        "file": await MultipartFile.fromFile(
            documentsFolderPath + '/thumbnail_${file.path.split('/').last}'),
      });
      var resPublicUrl = await Dio().post(uploadUrl, data: formData);
      print(resPublicUrl);
      if (resPublicUrl.statusCode == 200)
        return resPublicUrl.data as String;
      else
        throw Exception('Upload profile pic ended with problem');
    } else
      throw Exception('Creation file on server ended with problem');
  } catch (e) {
    print(e);
  }
}

Future<RecordResponce?> _createRecord(File file, String bearerToken,
    String? folderId, String documentsFolderPath) async {
  int numOfParts = _numOfParts(file);
  var query = {};
  print(SortByExtension().getFilesType(file.path.split('/').last));
  try {
    String file_type =
        SortByExtension().getFilesType(file.path.split('/').last);
    if (file_type == 'image') {
      if (folderId == null) {
        folderId = await getFotoVideoId(bearerToken, 'Photo');
      }
      query = {
        "data": {
          "name": "${file.path.split('/').last}",
          "folder":
              folderId /* ?? await getFotoVideoId(bearerToken, 'Photo')*/, // если подавать null, то файл создаётся в корень
          "numOfParts": numOfParts,
          "thumbnail": [
            {
              "name": "${file.path.split('/').last}",
              "sizeInBytes": 0,
              "privateUrl": "string",
              "publicUrl":
                  "${await uploadProfilePic(file: file, bearer_token: bearerToken, documentsFolderPath: documentsFolderPath)}",
              "new": true
            }
          ],
          "size": file.statSync().size,
          "copyStatus": 0,
          "tags": []
        }
      };
    } else if (file_type == 'video') {
      if (folderId == null) {
        folderId = await getFotoVideoId(bearerToken, 'Video');
      }
      query = {
        "data": {
          "name": "${file.path.split('/').last}",
          "folder": folderId, // если подавать null, то файл создаётся в корень
          "numOfParts": numOfParts,
          "thumbnail": [
            {
              "name": "$file_type",
              "sizeInBytes": 0,
              "privateUrl": "string",
              "publicUrl": "string",
              "new": true
            }
          ],
          "size": file.statSync().size,
          "copyStatus": 0,
          "tags": []
        }
      };
    } else {
      query = {
        "data": {
          "name": "${file.path.split('/').last}",
          "folder": folderId, // если подавать null, то файл создаётся в корень
          "numOfParts": numOfParts,
          "thumbnail": [
            {
              "name":
                  "${SortByExtension().getFilesType(file.path.split('/').last)}",
              "sizeInBytes": 0,
              "privateUrl": "string",
              "publicUrl": "string",
              "new": true
            }
          ],
          "size": file.statSync().size,
          "copyStatus": 0,
          "tags": []
        }
      };
    }

    var _dio =
        Dio(BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
    var response = await _dio.post(
      '/record',
      data: query,
      options: Options(
        headers: {'Authorization': ' Bearer $bearerToken'},
      ),
    );
    RecordResponce recResponce = RecordResponce.fromJson(response.data);

    print(response);
    return recResponce;
  } catch (e) {
    print(e);
    try {
      var _dio = Dio(
          BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
      var response = await _dio.post(
        '/record',
        data: query,
        options: Options(
          headers: {'Authorization': ' Bearer $bearerToken'},
        ),
      );
      RecordResponce recResponce = RecordResponce.fromJson(response.data);
      print(response.data);
      return recResponce;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

void _sendPart(SendPort sendPort) {
  ReceivePort isolateRecievePort = ReceivePort();
  developer.log('send port sent');
  sendPort.send(isolateRecievePort.sendPort);

  isolateRecievePort.listen((message) async {
    if (message is SendPartInfo) {
      developer.log('SendPartInfo received');
      DbPart part = DbPart(
        sessionID: message.storeds.locations!.first.session!,
        state: PartState.notEncrypted,
        transactionToken: message.storeds.locations!.first.transactionToken!,
      );
      try {
        Uint8List encryptedData =
            rsaEncrypt(message.publicKey, message.partFile);
        developer.log('parts successfully ecnrypted');
        part.state = PartState.encrypted;
        IOWebSocketChannel channel = IOWebSocketChannel.connect(
            'ws://${message.storeds.locations!.first.proxyIp}:${message.storeds.locations!.first.proxyPort}');
        //  final channel = IOWebSocketChannel.connect(
        //     'ws://95.216.228.24:${message.storeds.first.proxyPORT}');
        var query = {
          '"Transaction token"':
              '"${message.storeds.locations!.first.transactionToken}"',
          '"Init"': true,
        };
        channel.sink.add(query.toString());

        channel.stream.listen((socketMessage) async {
          if (socketMessage is String) {
            var decodeJson =
                Map<String, dynamic>.from(json.decode(socketMessage));
            if (decodeJson.containsKey("keepAlive") &&
                decodeJson["keepAlive"].toString().isNotEmpty) {
              channel.sink.add(json.encode({
                'keepAlive': 'keepAlive',
              }));
            } else if (decodeJson.containsKey('Ready_for_send')) {
              print('Ready_for_send');
              // var hash =  message.partFile.hashCode;
              final algorithm = Sha1();
              var hash = await algorithm.hash(encryptedData);
              part.partHash = hash.bytes.toString();
              var query = {
                '"filename"':
                    '"${message.storeds.locations!.first.transactionToken}"',
                '"hash"': '${hash.bytes}',
                '"Init"': '"True"',
              };
              channel.sink.add(query.toString());
              // sleep(Duration(milliseconds: 1));
              channel.sink.add(encryptedData);
              // encryptedData = null;
            }
            if (decodeJson.containsKey('result') &&
                decodeJson['result'] == 'Transmission OK!') {
              print("Transmission OK!");
              part.state = PartState.sended;
              // await _setHash(message.bearerToken,
              //     message.storeds.locations!.first.location!, part.partHash);
              SendPartResult res = SendPartResult(
                  index: message.index,
                  part: part,
                  locationId: message.storeds.locations!.first.location!,
                  hash: part.partHash);
              channel.sink.close();
              sendPort.send(res);
            }

            if (socketMessage == 'Transmission not OK!') {
              print("Transmission not OK!");
              part.state = PartState.notSended;
              SendPartResult res = SendPartResult(
                  index: message.index,
                  part: part,
                  locationId: message.storeds.locations!.first.location!,
                  hash: 'error');
              channel.sink.close();
              sendPort.send(res);
            }
          }
        });
      } catch (e) {
        print(e);
        SendPartResult res = SendPartResult(
            index: message.index,
            part: part,
            locationId: message.storeds.locations!.first.location!,
            hash: 'error');
        sendPort.send(res);
      }
    }
  });
}

Future<void> _setHash(String bearerToken, List<LocationHash> list) async {
  var query = {'locations': list.map((e) => e.toJson()).toList()};
  print(query.toString());
  try {
    var _dio =
        Dio(BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
    var response = await _dio.post(
      '/location/hash',
      data: query,
      options: Options(
        headers: {'Authorization': ' Bearer $bearerToken'},
      ),
    );
    print(response.data);
    //RecordResponse recResponce = RecordResponse.fromJson(response.data);
  } catch (e) {
    print(e);
    try {
      var _dio = Dio(
          BaseOptions(baseUrl: "https://upstorage.net/api/tenant/$tenantID"));
      var response = await _dio.post(
        '/location/hash',
        data: query,
        options: Options(
          headers: {'Authorization': ' Bearer $bearerToken'},
        ),
      );
      //RecordResponse recResponce = RecordResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class SendPartIsolateController {
  List<SendPartInfoWithState> parts;
  int aliveIsolatesCount = 0;
  final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> pair;
  final RecordResponce recordResponce;
  final SendData sendMessage;
  DBFileInfo fileInfo;
  Function(DBFileInfo) writeToDB;

  SendPartIsolateController(
      {required this.parts,
      required this.pair,
      required this.recordResponce,
      required this.sendMessage,
      required this.fileInfo,
      required this.writeToDB});

  Future<dynamic> manageIsolate() async {
    // print('launching manageisolate');
    List<LocationHash> hashes = [];
    int numOfActualThreads = 1;
    if (numOfThreads > parts.length) {
      numOfActualThreads = parts.length;
    } else {
      numOfActualThreads = numOfThreads;
    }
    print('numOfActualThreads = $numOfActualThreads');
    print('num of parts = ${parts.length}');
    for (int i = 0; i < numOfActualThreads; i++) {
      aliveIsolatesCount++;
      ReceivePort port = ReceivePort();
      Isolate isolate = await Isolate.spawn(_sendPart, port.sendPort);
      SendPort? sendPort;
      port.listen((message) async {
        if (message is SendPort) {
          sendPort = message;

          developer.log('send port received');
          parts[i].state = FileSendState.inProgress;
          message.send(parts[i].info);
        } else if (message is SendPartResult) {
          parts[i].state = FileSendState.sended;
          fileInfo = fileInfo.copyWith(message.part, null);
          hashes.add(
              LocationHash(hash: message.hash, locationId: message.locationId));
          try {
            var part = parts.firstWhere(
                (element) => element.state == FileSendState.available);
            SendPartInfo sendInfo = SendPartInfo(
                partFile: parts[parts.indexOf(part)].info.partFile,
                publicKey: pair.publicKey,
                storeds: recordResponce.parts![parts.indexOf(part)],
                privateKey: pair.privateKey,
                index: parts.indexOf(part),
                bearerToken: sendMessage.bearerToken);
            parts[parts.indexOf(part)].state = FileSendState.inProgress;
            sendPort?.send(sendInfo);
          } catch (e) {
            aliveIsolatesCount--;
            print(e);
            if (aliveIsolatesCount == 0) {
              _setHash(parts.first.info.bearerToken, hashes);
              print('Alive Isolates count == 0');
              fileInfo.privateKey = encodePrivateKeyToPem(pair.privateKey);
              isolate.kill();
              port.close();

              if (parts.first.info.storeds.locations!.length > 1) {
                print('${parts.first.info.storeds.locations!.length}');
                parts.forEach((element) {
                  element.state = FileSendState.available;
                  element.info.storeds.locations!.removeAt(0);
                });

                await manageIsolate();
              } else {
                writeToDB(fileInfo);
              }

              // return manageIsolate(null);
            }

            isolate.kill();
            port.close();
          }
        }
      });
    }
  }
}

class LocationHash {
  final String hash;
  final String locationId;
  LocationHash({
    required this.hash,
    required this.locationId,
  });

  Map<String, dynamic> toJson() {
    return {'id': locationId, 'hash': hash == 'error' ? null : hash};
  }
}
