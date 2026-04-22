import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Home Binding
/// Dependency injection untuk Home Page
/// Akan otomatis inject HomeController saat halaman home dibuka
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load - controller hanya dibuat saat dibutuhkan
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}