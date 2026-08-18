import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../controllers/CStorage/storagehome_controller.dart';
import '../controllers/CStorage/riwayat_gudang_controller.dart';
import '../controllers/profilecontroller.dart';

class StorageBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().changeTab(0);
    } else {
      Get.put<NavbarController>(NavbarController(), permanent: true);
    }
    Get.put<StorageHomeController>(StorageHomeController());
    Get.put<RiwayatGudangController>(RiwayatGudangController());

    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}