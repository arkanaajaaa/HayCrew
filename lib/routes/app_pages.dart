// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:haycrew_app/bindings/laporan_binding.dart';
import 'package:haycrew_app/bindings/permintaan_binding.dart';
import 'package:haycrew_app/pages/dashboard/kandang/laporkandangpage.dart';
import 'package:haycrew_app/pages/dashboard/kandang/permintaankandang_page.dart';
import 'package:haycrew_app/pages/dashboard/kandang/main_shell_pagekandang.dart'; // BARU
import '../pages/loginpage.dart';
import '../bindings/login_binding.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // DASHBOARD sekarang mengarah ke MainShellPage
    GetPage(
      name: AppRoutes.DASHBOARD_KANDANG,
      page: () => const MainShellPage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Laporan & Permintaan tetap sebagai route terpisah — tidak berubah
    GetPage(
      name: AppRoutes.LAPOR_KANDANG,
      page: () => const LaporanPage(),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: AppRoutes.KIRIM_PERMINTAAN,
      page: () => const PermintaanKandangPage(),
      binding: PermintaanBinding(),
    ),

    // HAPUS route PROFIL — profil sekarang bagian dari shell
  ];
}