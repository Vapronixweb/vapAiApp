import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceTokenUtil {
  static Future<String> getDeviceToken() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id; // unique per device
    }

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? "ios-unknown";
    }

    return "unknown-device";
  }
}
