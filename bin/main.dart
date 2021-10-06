import 'dart:async';
import '../lib/cpp_native.dart';



void main(List<String> arguments) async {
  void variable = await startListen();
  while(true){}
}

Future<void> startListen() async {
  CppNative cpp = CppNative();
  await cpp.receiver(
      '615181c28f1f5a686a9151f5',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwYWFjMDQzNzkzNDUzNzUxYWI4NGNiYSIsImlhdCI6MTYzMzUwNTQ1MCwiZXhwIjoxNjM0MTEwMjUwfQ.P6teoJt6-ShjafsYKfIbW8YtQfPu3XOGdaSLUf4d8nY');
}
