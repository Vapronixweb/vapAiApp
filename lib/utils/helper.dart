import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceToken() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    return (await deviceInfo.androidInfo).id;
  } else {
    return (await deviceInfo.iosInfo).identifierForVendor!;
  }
}
