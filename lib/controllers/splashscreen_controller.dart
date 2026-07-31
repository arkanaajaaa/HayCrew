import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/utils/name_utils.dart';

/// SplashscreenController — cek sesi login yang tersimpan (token + user)
/// begitu app dibuka. Kalau masih valid, langsung lempar ke dashboard yang
/// sesuai role (kandang/gudang) TANPA perlu login ulang. Kalau tidak ada
/// atau datanya rusak, baru diarahkan ke halaman Login.
///
/// Ini yang bikin akun "tetap login" walau app di-close — karena GetStorage
/// memang sudah nyimpen token ke disk, splash ini cuma nambahin pengecekan
/// yang tadinya belum ada di main.dart (yang selalu buka ke Login).
class SplashscreenController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Jeda kecil biar splash sempat kelihatan sebentar, sekaligus kasih
    // waktu GetStorage benar-benar siap dibaca.
    await Future.delayed(const Duration(milliseconds: 800));

    final token = _storage.read('token');
    final user = _storage.read('user');

    if (token == null || token.toString().isEmpty || user == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    final role = (user['role'] ?? '').toString().toLowerCase();
    final name = nicknameFrom(user['name']?.toString());
    final userId = user['id']?.toString() ?? '';
    final photoUrl = user['foto_url']?.toString();
    final email = user['email']?.toString();

    final args = {
      'userName': name,
      'userRole': role,
      'userId': userId,
      'userPhotoUrl': photoUrl,
      'userEmail': email,
    };

    switch (role) {
      case 'kandang':
        Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG, arguments: args);
        break;
      case 'gudang':
        Get.offAllNamed(AppRoutes.DASHBOARD_STORAGE, arguments: args);
        break;
      default:
        // Role belum didukung dashboard-nya (reseller/admin) atau data user
        // rusak/nggak lengkap -> aman balik ke Login daripada nyangkut di splash.
        Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}