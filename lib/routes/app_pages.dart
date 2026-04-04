import 'package:get/get.dart';
import '../pages/loginpage.dart';
import '../pages/dashboard/kandang/homepagekandang.dart';
import '../bindings/login_binding.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

/// App Pages
/// Berisi konfigurasi semua halaman dengan routes dan bindings
class AppPages {
  // Prevent instantiation
  AppPages._();

  /// Initial Route
  static const INITIAL = AppRoutes.INITIAL;

  /// Get Pages - List semua halaman aplikasi
  static final routes = [
    // Login Page
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Home Dashboard Kandang
    GetPage(
      name: AppRoutes.DASHBOARD_KANDANG,
      page: () => const HomePageKandang(
        userName: 'User',
        userRole: 'Karyawan Kandang',
      ),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // TODO: Tambahkan routes lainnya di sini
    // GetPage(
    //   name: AppRoutes.LAPOR_KANDANG,
    //   page: () => LaporKandangPage(),
    //   binding: LaporKandangBinding(),
    // ),
  ];
}