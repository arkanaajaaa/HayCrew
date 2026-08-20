/// lib/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:haycrew_app/bindings/laporan_binding.dart';
import 'package:haycrew_app/bindings/permintaan_binding.dart';
import 'package:haycrew_app/bindings/storage_binding.dart';
import 'package:haycrew_app/bindings/tambahstok_binding.dart';
import 'package:haycrew_app/bindings/laporanstok_binding.dart';
import 'package:haycrew_app/pages/dashboard/kandang/laporkandangpage.dart';
import 'package:haycrew_app/pages/dashboard/kandang/permintaankandang_page.dart';
import 'package:haycrew_app/pages/dashboard/kandang/main_shell_pagekandang.dart';
import 'package:haycrew_app/pages/dashboard/storage/mainshell_pagestorage.dart';
import 'package:haycrew_app/pages/dashboard/storage/tambahstokpage.dart';
import 'package:haycrew_app/pages/dashboard/storage/laporanstokpage.dart';
import 'package:haycrew_app/bindings/splash_binding.dart';
import 'package:haycrew_app/pages/splashscreen_page.dart';
import 'package:haycrew_app/pages/dashboard/kandang/riwayatkandang_page.dart';
import 'package:haycrew_app/pages/dashboard/storage/riwayatstorage_page.dart';
import 'package:haycrew_app/pages/notifikasipage.dart';

import '../pages/loginpage.dart';
import '../bindings/login_binding.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashscreenPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.DASHBOARD_KANDANG,
      page: () => const MainShellPage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.LAPOR_KANDANG,
      page: () => LaporanPage(),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: AppRoutes.KIRIM_PERMINTAAN,
      page: () => PermintaanKandangPage(),
      binding: PermintaanBinding(),
    ),

    GetPage(
      name: AppRoutes.DASHBOARD_STORAGE,
      page: () => const MainShellPageStorage(),
      binding: StorageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.TAMBAH_STOK,
      page: () => TambahStokPage(),
      binding: TambahStokBinding(),
    ),
    GetPage(
      name: AppRoutes.LAPORAN_STOK,
      page: () => const LaporanStokPage(),
      binding: LaporanStokBinding(),
    ),
    GetPage(
      name: AppRoutes.RIWAYAT_STORAGE,
      page: () => const RiwayatStoragePage()
    ),
    GetPage(
      name: AppRoutes.RIWAYAT_KANDANG,
      page: () => const RiwayatKandangPage(),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotifikasiPage(),
    ),
  ];
}