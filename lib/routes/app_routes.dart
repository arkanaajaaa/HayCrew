/// lib/routes/app_routes.dart

class AppRoutes {
  AppRoutes._();

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String LOGIN           = '/login';
  static const String REGISTER        = '/register';
  static const String FORGOT_PASSWORD = '/forgot-password';

  // ─── Splash ───────────────────────────────────────────────────────────────
  static const String SPLASH = '/splash';

  // ─── Dashboard Kandang ────────────────────────────────────────────────────
  static const String DASHBOARD_KANDANG = '/dashboard-kandang';
  static const String LAPOR_KANDANG     = '/lapor-kandang';
  static const String KIRIM_PERMINTAAN  = '/kirim-permintaan';
  static const String DETAIL_STATUS     = '/detail-status';

  // ─── Dashboard Storage ────────────────────────────────────────────────────
  static const String DASHBOARD_STORAGE = '/dashboard-storage';
  // Tambahkan sub-route storage di sini (misal: /storage/tambah-stok)

  // ─── Dashboard Reseller ───────────────────────────────────────────────────
  static const String DASHBOARD_RESELLER = '/dashboard-reseller';
  // Tambahkan sub-route reseller di sini

  // ─── Shared ───────────────────────────────────────────────────────────────
  static const String RIWAYAT       = '/riwayat';
  static const String PROFIL        = '/profil';
  static const String SETTINGS      = '/settings';
  static const String NOTIFICATIONS = '/notifications';

  // ─── Initial Route ────────────────────────────────────────────────────────
  static const String INITIAL = LOGIN;
}

















// /// App Routes
// /// Berisi semua nama route yang digunakan di aplikasi
// class AppRoutes {
//   AppRoutes._();

//   // ─── Auth Routes ──────────────────────────────────────────────────────────
//   static const String LOGIN           = '/login';
//   static const String REGISTER        = '/register';
//   static const String FORGOT_PASSWORD = '/forgot-password';

//   // ─── Splash ───────────────────────────────────────────────────────────────
//   static const String SPLASH = '/splash';

//   // ─── Dashboard Routes — Kandang ───────────────────────────────────────────
//   static const String DASHBOARD_KANDANG  = '/dashboard-kandang';
//   static const String LAPOR_KANDANG      = '/lapor-kandang';
//   static const String KIRIM_PERMINTAAN   = '/kirim-permintaan';
//   static const String DETAIL_STATUS      = '/detail-status';

//   // ─── Dashboard Routes — Storage ───────────────────────────────────────────
//   static const String DASHBOARD_STORAGE  = '/dashboard-storage';
//   // Tambahkan sub-route storage di sini sesuai kebutuhan

//   // ─── Dashboard Routes — Reseller ──────────────────────────────────────────
//   static const String DASHBOARD_RESELLER = '/dashboard-reseller';
//   // Tambahkan sub-route reseller di sini sesuai kebutuhan

//   // ─── Shared Routes (bisa diakses semua role) ──────────────────────────────
//   static const String RIWAYAT       = '/riwayat';
//   static const String PROFIL        = '/profil';
//   static const String SETTINGS      = '/settings';
//   static const String NOTIFICATIONS = '/notifications';

//   // ─── Initial Route ────────────────────────────────────────────────────────
//   static const String INITIAL = LOGIN;
// }