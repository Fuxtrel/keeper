import 'dart:io';

// import 'package:encrypt/encrypt.dart';
import "package:pointycastle/export.dart";
import 'package:pointycastle/src/platform_check/platform_check.dart';

bool isExistKeys(String path) {
  Directory dir = Directory(path);
  var keys = dir.listSync();
  bool result = true;
  if (keys.isNotEmpty && keys.length == 2) {
    keys.forEach((element) {
      if (!(element.path.split(".").last == 'pem') ||
          element.statSync().size == 0) {
        result = false;
      }
    });
  }
  return result;
}

void genKeys(String path) {
  // SecureRandom secureRandom;
  final secureRandom = SecureRandom('Fortuna')
    ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  int bitLength = 1024;
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom));
  final pair = keyGen.generateKeyPair();
  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  // print(myPrivate.toString());
}
