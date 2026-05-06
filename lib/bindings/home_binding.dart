// lib/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navbar_controller.dart';
// Tambahkan controller yang dibutuhkan halaman-halaman di shell
import '../controllers/profilecontroller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // NavbarController permanent — satu instance untuk seluruh shell
    Get.put<NavbarController>(NavbarController(), permanent: true);

    Get.lazyPut<HomeController>(() => HomeController());

    // ProfilController sekarang hidup di shell yang sama
    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}