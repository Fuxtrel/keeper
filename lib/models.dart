part of cpp_native;

const String tenantID = "608c0906cb5fb91ccf8bf5a5";
const int numOfThreads = 10;

class SendData {
  final String documentsFolderPath;
  final String filePath;
  final String bearerToken;
  final String? folderId;

  SendData(
      {required this.documentsFolderPath,
      required this.filePath,
      required this.bearerToken,
      this.folderId});
}

class RecievePartIsolateInfo {
  String token;
  String path;
  final String proxyIP;
  final String proxyPort;

  RecievePartIsolateInfo({
    required this.path,
    required this.token,
    required this.proxyIP,
    required this.proxyPort,
  });
}

class RecievePartInfo {
  final String token;
  final Isolate isolate;
  final ReceivePort port;

  RecievePartInfo({
    required this.isolate,
    required this.port,
    required this.token,
  });
}

class SendPartInfo {
  final Uint8List partFile;
  final RSAPublicKey publicKey;
  final Part storeds;
  final RSAPrivateKey privateKey;
  final int index;
  final String bearerToken;

  SendPartInfo({
    required this.partFile,
    required this.storeds,
    required this.publicKey,
    required this.privateKey,
    required this.index,
    required this.bearerToken,
  });
}

class SendPartResult {
  final String locationId;
  final String hash;
  final int index;
  final DbPart part;

  SendPartResult({
    required this.index,
    required this.part,
    required this.locationId,
    required this.hash,
  });
}

class DownloadOption {
  final String recordID;
  final String bearerToken;
  final Directory pathToDir;

  DownloadOption({
    required this.bearerToken,
    required this.recordID,
    required this.pathToDir,
  });
}

class DownloadPartIsolate {
  final String uploadTransactionToken;
  Uint8List? filePart;
  FileSendState state = FileSendState.available;

  DownloadPartIsolate({
    required this.uploadTransactionToken,
    this.filePart,
  });
}

class SendPartInfoWithState {
  final SendPartInfo info;
  FileSendState state = FileSendState.available;
  SendPartInfoWithState({
    required this.info,
  });
}

enum FileSendState {
  available,
  inProgress,
  sended,
}
