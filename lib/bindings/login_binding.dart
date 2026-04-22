import 'package:get/get.dart';
import '../controllers/loginController.dart';

/// Login Binding
/// Dependency injection untuk Login Page
/// Akan otomatis inject LoginController saat halaman login dibuka
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load - controller hanya dibuat saat dibutuhkan
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}