import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final GetStorage _box = GetStorage();

  // Keys
  static const String deviceTokenKey = "device_token";
  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";
  static const String userKey = "user";
  static const String isLoggedInKey = "is_logged_in";

  /* ================= DEVICE ================= */

  static void saveDeviceToken(String token) {
    _box.write(deviceTokenKey, token);
  }

  static String? getDeviceToken() {
    return _box.read(deviceTokenKey);
  }

  /* ================= AUTH ================= */

  static void saveAuth({
    required String accessToken,
    String? refreshToken,
  }) {
    _box.write(accessTokenKey, accessToken);
    if (refreshToken != null) {
      _box.write(refreshTokenKey, refreshToken);
    }
    _box.write(isLoggedInKey, true);
  }

  static String? getAccessToken() {
    return _box.read(accessTokenKey);
  }

  static bool isLoggedIn() {
    return _box.read(isLoggedInKey) ?? false;
  }

  /* ================= USER ================= */

  static void saveUser(Map<String, dynamic> userJson) {
    _box.write(userKey, userJson);
  }

  static Map<String, dynamic>? getUser() {
    return _box.read(userKey);
  }

  /* ================= LOGOUT ================= */

  static void clearAll() {
    _box.erase();
  }
}
