/// App Routes
/// Berisi semua nama route yang digunakan di aplikasi
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Auth Routes
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String FORGOT_PASSWORD = '/forgot-password';

  // Main Routes
  static const String HOME = '/home';
  static const String SPLASH = '/splash';

  // Dashboard Routes - Kandang
  static const String DASHBOARD_KANDANG = '/dashboard-kandang';
  static const String LAPOR_KANDANG = '/lapor-kandang';
  static const String KIRIM_PERMINTAAN = '/kirim-permintaan';
  static const String DETAIL_STATUS = '/detail-status';

  // Other Routes
  static const String RIWAYAT = '/riwayat';
  static const String PROFIL = '/profil';
  static const String SETTINGS = '/settings';
  static const String NOTIFICATIONS = '/notifications';

  // Initial Route
  static const String INITIAL = LOGIN;
}
