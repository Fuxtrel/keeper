import 'dart:async';
import 'package:keeper/cpp_native.dart';
import 'dart:io';



void main(List<String> arguments) async {
  await startListen();
  while(true){}
}

Future<void> startListen() async {
  File file_kid = File('./keeper_id.txt');
  File file_bt = File('./bearer_token.txt');
  String keeper_id = '';
  String bearer_token = '';
  keeper_id = file_kid.readAsStringSync();
  bearer_token = file_bt.readAsStringSync();
  CppNative cpp = CppNative();
  cpp.receiver(
      keeper_id,
      bearer_token);
}
