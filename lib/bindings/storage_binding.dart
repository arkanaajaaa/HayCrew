/// lib/bindings/storage_binding.dart

import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../controllers/CStorage/storagehome_controller.dart';
import '../controllers/profilecontroller.dart';

class StorageBinding extends Bindings {
  @override
  void dependencies() {
    // NavbarController permanent — sama seperti di HomeBinding
    Get.put<NavbarController>(NavbarController(), permanent: true);

    // Controller utama storage
    Get.lazyPut<StorageHomeController>(() => StorageHomeController());

    // ProfilController shared — dipakai di tab Profil
    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}