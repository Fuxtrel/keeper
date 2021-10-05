import 'dart:async';
import '../lib/cpp_native.dart';

void main(List<String> arguments) {
  startListen();
  while (true);
}

Future<void> startListen() async {
  // File file = File('./keeper.txt');
  // String keeperId = file.readAsStringSync();
  CppNative cpp = CppNative();
  cpp.receiver(
      '615181c28f1f5a686a9151f5',
      // _controllerToken.text,
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwYWFjMDQzNzkzNDUzNzUxYWI4NGNiYSIsImlhdCI6MTYzMzQzMjI4MywiZXhwIjoxNjM0MDM3MDgzfQ.zc1X9kiKgKYHooFVPRfJRgsfuOjGZOmLU3NXQB8AewQ');
  // cpp.receiver('615181c28f1f5a686a9151f5',
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwYWFjMDQzNzkzNDUzNzUxYWI4NGNiYSIsImlhdCI6MTYzMjcyNjgwOCwiZXhwIjoxNjMzMzMxNjA4fQ.1inFtzazejNFq_PcXwCSx3S8WCf02NrP4B9AUkhoG-Y");
}
