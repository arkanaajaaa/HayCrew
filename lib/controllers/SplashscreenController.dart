import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haycrew_app/routes/routes.dart';

class Splashscreencontroller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString("username") != null) {
      Get.offAllNamed(AppRoutes.homePage);
    } else {
      Get.offAllNamed(AppRoutes.loginPage);
    }
  }
}
