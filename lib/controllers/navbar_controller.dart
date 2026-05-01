import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/routes/app_routes.dart';

class NavbarController extends GetxController {
  var currentNavIndex = 0.obs;

  void changeNavIndex(int index) {
    switch (index) {
      case 0:
        if (Get.currentRoute != AppRoutes.DASHBOARD_KANDANG) {
          Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG);
        }
        break;
      case 1:
        _showComingSoon('Riwayat');
        return; // jangan update index kalau tidak jadi navigasi
      case 2:
        if (Get.currentRoute != AppRoutes.PROFIL) {
          Get.toNamed(AppRoutes.PROFIL);
        }
        break;
    }
    currentNavIndex.value = index;
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Info',
      'Fitur $feature akan segera tersedia',
      snackPosition:   SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText:       Colors.blue[900],
      margin:          const EdgeInsets.all(15),
      duration:        const Duration(seconds: 2),
    );
  }
}