import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://YOUR_SERVER/api/v1";

  static Future<Map<String, dynamic>> deviceLogin(String deviceToken) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/device-login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"device_token": deviceToken}),
    );

    return jsonDecode(res.body);
  }
}
