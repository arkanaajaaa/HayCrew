import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navbar_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // NavbarController di-register permanen di sini (permanent: true)
    // agar instance-nya tetap sama dan bisa di-Get.find() dari mana saja
    // termasuk dari CBottomNav di ProfilPage
    Get.put<NavbarController>(NavbarController(), permanent: true);

    Get.lazyPut<HomeController>(() => HomeController());
  }
}