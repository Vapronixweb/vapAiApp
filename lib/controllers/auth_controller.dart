import 'package:get/get.dart';

import '../storage/local_storage.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    isLoggedIn.value = LocalStorage.isLoggedIn();
    super.onInit();
  }

  void logout() {
    LocalStorage.clearAll();
    isLoggedIn.value = false;
    Get.offAllNamed("/onboarding");
  }
}
