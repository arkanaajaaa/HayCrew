import 'package:get/get.dart';
import 'package:haycrew_app/bindings/laporan_binding.dart';
import 'package:haycrew_app/bindings/permintaan_binding.dart';
import 'package:haycrew_app/bindings/profile_binding.dart';                         // BARU
import 'package:haycrew_app/pages/dashboard/kandang/laporkandangpage.dart';
import 'package:haycrew_app/pages/dashboard/kandang/permintaankandang_page.dart';
import 'package:haycrew_app/pages/dashboard/kandang/profilepage.dart';                         // BARU
import '../pages/loginpage.dart';
import '../pages/dashboard/kandang/homepagekandang.dart';
import '../bindings/login_binding.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    // Login
    GetPage(
      name:       AppRoutes.LOGIN,
      page:       () => const LoginPage(),
      binding:    LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Dashboard Kandang
    GetPage(
      name:       AppRoutes.DASHBOARD_KANDANG,
      page:       () => const HomePageKandang(
        userName: 'User',
        userRole: 'Karyawan Kandang',
      ),
      binding:    HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Laporan Kandang
    GetPage(
      name:    AppRoutes.LAPOR_KANDANG,
      page:    () => const LaporanPage(),
      binding: LaporanBinding(),
    ),

    // Permintaan Dana / Barang
    GetPage(
      name:    AppRoutes.KIRIM_PERMINTAAN,
      page:    () => const PermintaanKandangPage(),
      binding: PermintaanBinding(),
    ),

    // Profil
    GetPage(
      name:    AppRoutes.PROFIL,
      page:    () => const ProfilPage(),
      binding: ProfilBinding(),
    ),
  ];
}