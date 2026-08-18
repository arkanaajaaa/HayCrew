import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navbar_controller.dart';
import '../controllers/profilecontroller.dart';
import '../controllers/CKandang/riwayat_kandang_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().changeTab(0);
    } else {
      Get.put<NavbarController>(NavbarController(), permanent: true);
    }
    Get.put<HomeController>(HomeController());
    Get.put<RiwayatKandangController>(RiwayatKandangController());

    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}