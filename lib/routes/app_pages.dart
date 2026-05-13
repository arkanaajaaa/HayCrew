/// lib/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:haycrew_app/bindings/laporan_binding.dart';
import 'package:haycrew_app/bindings/permintaan_binding.dart';
import 'package:haycrew_app/bindings/storage_binding.dart';
import 'package:haycrew_app/pages/dashboard/kandang/laporkandangpage.dart';
import 'package:haycrew_app/pages/dashboard/kandang/permintaankandang_page.dart';
import 'package:haycrew_app/pages/dashboard/kandang/main_shell_pagekandang.dart';
import 'package:haycrew_app/pages/dashboard/storage/mainshell_pagestorage.dart';

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

    GetPage(
      name: AppRoutes.DASHBOARD_KANDANG,
      page: () => const MainShellPage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
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

    GetPage(
      name: AppRoutes.DASHBOARD_STORAGE,
      page: () => const MainShellPageStorage(),
      binding: StorageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

















// // lib/routes/app_pages.dart
// import 'package:get/get.dart';
// import 'package:haycrew_app/bindings/laporan_binding.dart';
// import 'package:haycrew_app/bindings/permintaan_binding.dart';
// import 'package:haycrew_app/pages/dashboard/kandang/laporkandangpage.dart';
// import 'package:haycrew_app/pages/dashboard/kandang/permintaankandang_page.dart';
// import 'package:haycrew_app/pages/dashboard/kandang/main_shell_pagekandang.dart';

// // TODO: Import shell page untuk storage dan reseller saat sudah dibuat
// // import 'package:haycrew_app/pages/dashboard/storage/main_shell_pagestorage.dart';
// // import 'package:haycrew_app/pages/dashboard/reseller/main_shell_pagereseller.dart';
// // import 'package:haycrew_app/bindings/storage_binding.dart';
// // import 'package:haycrew_app/bindings/reseller_binding.dart';

// import '../pages/loginpage.dart';
// import '../bindings/login_binding.dart';
// import '../bindings/home_binding.dart';
// import 'app_routes.dart';

// class AppPages {
//   AppPages._();

//   static const INITIAL = AppRoutes.INITIAL;

//   static final routes = [
//     // ─── Auth ─────────────────────────────────────────────────────────────
//     GetPage(
//       name: AppRoutes.LOGIN,
//       page: () => const LoginPage(),
//       binding: LoginBinding(),
//       transition: Transition.fadeIn,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),

//     // ─── Dashboard Kandang ────────────────────────────────────────────────
//     GetPage(
//       name: AppRoutes.DASHBOARD_KANDANG,
//       page: () => const MainShellPage(),
//       binding: HomeBinding(),
//       transition: Transition.fadeIn,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//     GetPage(
//       name: AppRoutes.LAPOR_KANDANG,
//       page: () => const LaporanPage(),
//       binding: LaporanBinding(),
//     ),
//     GetPage(
//       name: AppRoutes.KIRIM_PERMINTAAN,
//       page: () => const PermintaanKandangPage(),
//       binding: PermintaanBinding(),
//     ),

//     // ─── Dashboard Storage ─────────────────────────────────────────────────
//     // TODO: Uncomment saat StorageDashboard sudah dibuat
//     // GetPage(
//     //   name: AppRoutes.DASHBOARD_STORAGE,
//     //   page: () => const MainShellPageStorage(),
//     //   binding: StorageBinding(),
//     //   transition: Transition.fadeIn,
//     // ),

//     // ─── Dashboard Reseller ────────────────────────────────────────────────
//     // TODO: Uncomment saat ResellerDashboard sudah dibuat
//     // GetPage(
//     //   name: AppRoutes.DASHBOARD_RESELLER,
//     //   page: () => const MainShellPageReseller(),
//     //   binding: ResellerBinding(),
//     //   transition: Transition.fadeIn,
//     // ),
//   ];
// }