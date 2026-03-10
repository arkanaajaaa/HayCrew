import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoggedIn = false.obs;

  void login() async {
    if (usernameController.text == "admin" &&
        passwordController.text == "admin") {
      isLoggedIn.value = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("username", usernameController.text.toString());
      Get.snackbar("Success", "Login berhasil");
      Get.offNamed(AppRoutes.homePage);
    } else {
      Get.snackbar("Error", "Username / Password salah");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.splashscreenpage);
    Get.snackbar("Logout", "Berhasil keluar");
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
