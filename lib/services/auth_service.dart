import 'dart:convert';
import 'package:ai_app/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<Map<String, dynamic>> deviceLogin(String deviceToken) async {
    final res = await http.post(
      Uri.parse("$apiUrl/device-login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"device_token": deviceToken}),
    );

    if (kDebugMode) {
      print(res.body);
    }
    return jsonDecode(res.body);
  }
}
