part of cpp_native;

void _receive(List<String> params) async {
  // File file = File((await getApplicationSupportDirectory()).path + '/qawszecgioujkhj.txt');
  // file.create();
  // print(file.existsSync());
  final channel = IOWebSocketChannel.connect('ws://95.216.228.24:4040');
  // final channel = IOWebSocketChannel.connect('ws://localhost:4040');
  var query = {
    '"keeper_id"': '"${params[1]}"',
  };
  final token = params[2];
  // print (query.toString());
  channel.sink.add(query.toString());

  List<RecievePartInfo> isolateList = [];
  channel.stream.listen((data) async {
    print('Message from proxy: $data');
    var decodeJson = Map<String, dynamic>.from(json.decode(data));
    if (decodeJson.containsKey("keepAlive") &&
        decodeJson["keepAlive"].toString().isNotEmpty) {
      channel.sink.add(json.encode({
        'keepAlive': 'keepAlive',
      }));
    } else {
      if (decodeJson.containsKey("keeper_state_online")) {
        throw Exception('keeper_state_online: false');
      }
      try {
        print('Message from main proxy: $data');
        var str = data;
        if (str[0] == '{') {
          var message = json.decode(str);
          String token = message['transaction token'];
          bool download = message['download'];
          String proxyIP = message['ip'];
          int proxyPort = message['port'];
          var port = ReceivePort();
          if (!download) {
            var isolate = await Isolate.spawn(_partRecieve, port.sendPort);
            isolateList.add(
              RecievePartInfo(
                isolate: isolate,
                port: port,
                token: token,
              ),
            );

            port.listen((message) {
              if (message is SendPort) {
                var info = RecievePartIsolateInfo(
                    path: params[0],
                    token: token,
                    proxyIP: proxyIP,
                    proxyPort: proxyPort.toString());
                message.send(info);
              } else if (message is String) {
                var iso = isolateList.firstWhere(
                  (element) => element.token == message,
                );
                iso.isolate.kill();
                iso.port.close();
                isolateList.remove(iso);
              }
            });
          } else {
            var isolate = await Isolate.spawn(_partUpload, port.sendPort);
            port.listen((message) {
              if (message is SendPort) {
                var info = RecievePartIsolateInfo(
                    path: params[0],
                    token: token,
                    proxyIP: proxyIP,
                    proxyPort: proxyPort.toString());
                message.send(info);
              }
              if (message is bool) {
                isolate.kill();
                port.close();
              }
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }).onDone(() {return;});
}

class _FilenameHashJson {
  final String filename;
  final List<int> hash;
  final String init;
  _FilenameHashJson({
    required this.filename,
    required this.hash,
    required this.init,
  });

  _FilenameHashJson.fromJson(Map<String, dynamic> map)
      : this.filename = map['filename'] as String,
        this.hash = List.from(map['hash']),
        this.init = map['Init'] as String;
}

void _partRecieve(SendPort sendPort) {
  ReceivePort isolateRecievePort = ReceivePort();
  sendPort.send(isolateRecievePort.sendPort);
  isolateRecievePort.listen((message) {
    if (message is RecievePartIsolateInfo) {
      final channel = IOWebSocketChannel.connect(
          'ws://${message.proxyIP}:${message.proxyPort}');
      // final channel = IOWebSocketChannel.connect('ws://localhost:4041');

      var query = {
        '"Transaction token"': '"${message.token}"',
        '"Init"': true,
      };

      channel.sink.add(query.toString());
      bool isReady = false;
      Map<String, dynamic>? jsonValue;
      _FilenameHashJson? fileInfoJson;
      channel.stream.listen((socketMessage) async {
        // print(String.fromCharCodes(socketMessage));
        // try{

        if (socketMessage is Uint8List) {
          // print(socketMessage.toString());
          var file = socketMessage;
          final algorithm = Sha1();
          var hash = await algorithm.hash(file);
          // print (file);

          print('Hashes match: ${fileInfoJson?.hash.toString() == hash.bytes.toString()}');

          if (fileInfoJson?.hash.toString() == hash.bytes.toString()) {
            print('Transmission OK!');
            developer.log('hashes on keeper side matches');
            channel.sink.add(json.encode({'result': 'Transmission OK!'}));
            var name = fileInfoJson?.filename;
            File newFile = File(message.path + '/' + name!);
            newFile.createSync(recursive: true);
            newFile.writeAsBytesSync(file);
            // channel.sink.close();
            // sendPort.send(message.token);
          } else {
            print('Transmission not OK!');
            channel.sink.add(json.encode({'result': 'Transmission not OK!'}));
            // channel.sink.close();
            // sendPort.send(message.token);
          }
        }
        if (socketMessage is String) {
          // print(socketMessage);
          var decodeJson =
              Map<String, dynamic>.from(json.decode(socketMessage));
          if (decodeJson.containsKey("keepAlive") &&
              decodeJson["keepAlive"].toString().isNotEmpty) {
            try {
              channel.sink.add(json.encode({
                'keepAlive': 'keepAlive',
              }));
            } catch (e) {}
          } else if (decodeJson.containsKey("done") &&
              decodeJson["done"].toString().isNotEmpty) {
            channel.sink.close();
            sendPort.send(message.token);
          } else if (decodeJson.containsKey('filename')) {
            print(socketMessage);
            fileInfoJson = _FilenameHashJson.fromJson(decodeJson);
            channel.sink.add(json.encode({'fileData': 'ok'}));
          } else if (decodeJson.containsKey('Ready_for_send')) {
            print('RECIVER Ready for send');
            isReady = true;
          }
        }
      });
    }
  });
}

void _partUpload(SendPort sendPort) async {
  ReceivePort isolateRecievePort = ReceivePort();
  sendPort.send(isolateRecievePort.sendPort);

  isolateRecievePort.listen((message) {
    if (message is RecievePartIsolateInfo) {
      final channel = IOWebSocketChannel.connect(
          'ws://${message.proxyIP}:${message.proxyPort}');
      var query = {
        '"Transaction token"': '"${message.token}"',
        '"Init"': true,
      };
      channel.sink.add(query.toString());
      bool isReady = false;
      Map<String, dynamic>? jsonValue;
      String filename = '';
      channel.stream.listen((socketMessage) async {
        // print(String.fromCharCodes(socketMessage));
        // try{
        if (socketMessage is String) {
          var decodeJson = json.decode(socketMessage);
          if (decodeJson.containsKey("keepAlive") &&
              decodeJson["keepAlive"].toString().isNotEmpty) {
            channel.sink.add(json.encode({
              'keepAlive': 'keepAlive',
            }));
          } else {
            if (isReady) {
              filename = decodeJson!['filename'];
              File uploadFile = File(message.path + '/' + filename);
              if (uploadFile.existsSync()) {
                Uint8List rawFile = uploadFile.readAsBytesSync();
                channel.sink.add(rawFile);
                sendPort.send(true);
              } else {
                channel.sink
                    .add(json.encode({'result': 'File doesn\'t exists'}));
                sendPort.send(false);
                // throw Exception('Upload: \t File doesn\'t exists');
              }
            }
            if (decodeJson['Ready_for_send'] == 'Ready_for_send') {
              isReady = true;
            }
          }
        }
      });
    }
  });
}
