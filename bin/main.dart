import 'dart:async';
import 'dart:convert';
import 'package:keeper/cpp_native.dart';
import 'dart:io';
import 'package:dio/dio.dart';

void main(List<String> arguments) async {
  await startListen();
  while (true) {}
}

Future<void> startListen() async {
  Response response = await getBearerToken();
  while (response.statusCode != 200) {
    response = await getBearerToken();
  }
  String bearer_token = response.data;
  String? keeper_id;
  print(bearer_token);
  if (File('./keeper_id.txt').existsSync() &&
      await File('./keeper_id.txt').length() != 0) {
    keeper_id = File('./keeper_id.txt').readAsStringSync();
  } else {
    File('./keeper_id.txt').createSync();
    response = await getKeeperId(bearer_token);
    while (response.statusCode != 200) {
      response = await getKeeperId(bearer_token);
    }
    Map<String, dynamic> json = response.data;
    keeper_id = json['id'];
    File('./keeper_id.txt').writeAsStringSync(keeper_id!);
    print(keeper_id);
    CppNative cpp = CppNative();
    cpp.receiver(keeper_id, bearer_token);
  }
}

Future<Response> getBearerToken() async {
  try {
    return await Dio().post('https://upstorage.net/api/auth/sign-in',
        options: Options(headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        }),
        data: json.encode({
          'email': 'a99som@yandex.ru',
          'password': 'z123x456',
          'invitationToken': 'string',
          'tenantId': 'string'
        }));
  } on DioError {
    return await getBearerToken();
  }
}

Future<Response> getKeeperId(String bearer_token) async {
  try {
    return await Dio().post('https://upstorage.net/api/tenant/12/keeper',
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $bearer_token',
          'Content-Type': ' application/json'
        }),
        data: json.encode({
          'data': {'connectionType': 'direct', 'space': 10, 'avarageSpeed': 0}
        }));
  } on DioError {
    return await getKeeperId(bearer_token);
  }
}
