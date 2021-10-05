import 'package:keeper/cpp_native.dart';

class SendFileRepository {
  final int fullSize;
  final int partsCount;
  final int partSize;
  int lastReadPosition = 0;
  int sendedPartsCount = 0;

  SendFileRepository({
    required this.fullSize,
    required this.partSize,
    required this.partsCount,
  });
}
