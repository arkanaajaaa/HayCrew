import 'package:get/get.dart';
import 'package:haycrew_app/controllers/splashscreen_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashscreenController>(SplashscreenController());
  }
}