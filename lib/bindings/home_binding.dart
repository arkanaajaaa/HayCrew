import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navbar_controller.dart';
import '../controllers/profilecontroller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavbarController>(NavbarController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);

    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}