import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final box = GetStorage();

  Rxn<UserModel> user = Rxn<UserModel>();
  RxString accessToken = ''.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final token = box.read("access_token");
    final userJson = box.read("user");

    if (token != null && userJson != null) {
      accessToken.value = token;
      user.value = UserModel.fromJson(userJson);
      isLoggedIn.value = true;
    }
  }

  void updateUser(Map<String, dynamic> userJson) {
    user.value = UserModel.fromJson(userJson);

    box.write("user", userJson);

    update();
  }

  Future<void> refreshUser() async {
    final response = await http.get(
      Uri.parse("$apiUrl/me"),
      headers: {
        "Authorization": "Bearer ${accessToken.value}",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      updateUser(body["data"]);
    }
  }



  Future<void> deviceLogin(String deviceToken) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/device-login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"device_token": deviceToken}),
      );

      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body["data"];

        accessToken.value = data["access_token"];
        user.value = UserModel.fromJson(data["user"]);
        // isLoggedIn.value = true;

        // Persist
        box.write("access_token", accessToken.value);
        box.write("user", data["user"]);
      }
    } catch (e) {
      Get.log("Device login failed: $e");
    }
  }

  void logout() {
    box.erase();
    user.value = null;
    accessToken.value = '';
    isLoggedIn.value = false;
    Get.offAllNamed("/onboarding");
  }
}
