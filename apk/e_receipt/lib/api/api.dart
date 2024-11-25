import 'dart:convert' show base64Decode, jsonDecode, jsonEncode, utf8;
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'dart:io';

class ApiService {
  static const String baseUrl = 'server.legatalee.me:8000';
  late http.Client httpClient;
  // late String accessHeaderValue;

  // 싱글톤 패턴 적용을 위한 인스턴스
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    httpClient = http.Client();
  }

  // // 서버 상태 확인
  // Future<int> pingServer() async {
  //   final url = Uri.http(baseUrl, '/status');
  //   final response = await http.get(
  //     url,
  //     headers: {'access': accessHeaderValue},
  //   );
  //   log("/status: <${response.statusCode}>, <${response.body}>");
  //   if (response.statusCode != 204) {
  //     log('Server Response : ${response.statusCode}');
  //   } else if (response.statusCode == 401) {
  //     //reissueToken;
  //     pingServer;
  //   }
  //   return response.statusCode;
  // }

  // 요청
  Future<String> getInfo(String id, String hash) async {
    try {
      final url = Uri.http(baseUrl, '/mobile', {'id': id, 'hash': hash});
      final response = await http.get(
        url,
      );
      log("/status: <${response.statusCode}>, <${response.body}>");
      if (response.statusCode != 200) {
        log('Server Response : ${response.statusCode}');
        return '-1';
      }
      return response.body;
    } catch (e) {
      log('Error: fail connect server - $e');
      return '-1';
    }
  }
}
