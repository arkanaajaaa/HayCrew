import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/routes/app_routes.dart';

class ProfilMenuItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;

  const ProfilMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });
}

class ProfilController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  // ─── Static precomputed colors ────────────────────────────────────────────
  static final _activeBgColor   = AppColors.lightGreen.withOpacity(0.15);
  static final _inactiveBgColor = AppColors.red.withOpacity(0.1);
  static final _logoutBgColor   = AppColors.red.withOpacity(0.1);

  // ─── User Data — mandiri, tidak bergantung HomeController ─────────────────
  final userName = 'User'.obs;
  final userRole = 'Karyawan'.obs;

  final joinDate = 'Karyawan sejak 12-02-2023'.obs;
  final isActive = true.obs;
  final isLoggingOut = false.obs;

  late final List<ProfilMenuItem> menuItems;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    menuItems = _buildMenuItems();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userName.value = args['userName'] ?? 'User';
      userRole.value = args['userRole'] ?? 'Karyawan';
    }
  }

  // ─── Computed ─────────────────────────────────────────────────────────────
  String get statusLabel   => isActive.value ? 'Aktif' : 'Nonaktif';
  Color  get statusColor   => isActive.value ? AppColors.primaryGreen : AppColors.red;
  Color  get statusBgColor => isActive.value ? _activeBgColor : _inactiveBgColor;

  // ─── Menu ─────────────────────────────────────────────────────────────────
  List<ProfilMenuItem> _buildMenuItems() => [
    ProfilMenuItem(
      icon: Icons.person_outline,
      iconBgColor: AppColors.calendarBackground,
      iconColor: AppColors.textDark,
      title: 'Informasi Pribadi',
      onTap: onTapInformasiPribadi,
    ),
    ProfilMenuItem(
      icon: Icons.settings_outlined,
      iconBgColor: AppColors.calendarBackground,
      iconColor: AppColors.textDark,
      title: 'Pengaturan Akun',
      onTap: onTapPengaturanAkun,
    ),
    ProfilMenuItem(
      icon: Icons.history,
      iconBgColor: AppColors.calendarBackground,
      iconColor: AppColors.orange,
      title: 'Riwayat Aktivitas',
      onTap: onTapRiwayatAktivitas,
    ),
    ProfilMenuItem(
      icon: Icons.security_outlined,
      iconBgColor: AppColors.calendarBackground,
      iconColor: AppColors.lightGreen,
      title: 'Keamanan',
      onTap: onTapKeamanan,
    ),
    ProfilMenuItem(
      icon: Icons.help_outline,
      iconBgColor: AppColors.calendarBackground,
      iconColor: AppColors.primaryGreen,
      title: 'Pusat Bantuan',
      onTap: onTapPusatBantuan,
    ),
    ProfilMenuItem(
      icon: Icons.logout,
      iconBgColor: _logoutBgColor,
      iconColor: AppColors.red,
      title: 'Keluar',
      onTap: onTapKeluar,
      isDanger: true,
    ),
  ];

  // ─── Actions ──────────────────────────────────────────────────────────────
  void onTapInformasiPribadi() => _showComingSoon('Informasi Pribadi');
  void onTapPengaturanAkun()   => _showComingSoon('Pengaturan Akun');
  void onTapRiwayatAktivitas() => _showComingSoon('Riwayat Aktivitas');
  void onTapKeamanan()         => _showComingSoon('Keamanan');
  void onTapPusatBantuan()     => _showComingSoon('Pusat Bantuan');

  void onTapKeluar() {
    if (isLoggingOut.value) return; // cegah double-tap pas dialog kebuka
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _doLogout,
            child: Text(
              'Keluar',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Logout beneran: hapus token & data user dari GetStorage (bukan cuma
  /// pindah halaman) supaya splash screen nggak nemuin sesi lama lagi pas
  /// app dibuka ulang. Panggil endpoint /api/logout dulu (best-effort, kalau
  /// gagal/timeout tetap lanjut hapus sesi lokal) sama persis kayak
  /// LoginController.handleLogout().
  Future<void> _doLogout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;

    Get.back(); // tutup dialog konfirmasi dulu

    final token = _token;
    try {
      await http
          .post(
            Uri.parse('${ApiConstant.baseUrl}/api/logout'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Diabaikan dengan sengaja: mau server-nya sukses atau gagal/offline,
      // sesi lokal tetap harus dihapus supaya user beneran keluar.
    }

    await _storage.erase();
    Get.offAllNamed(AppRoutes.LOGIN);

    isLoggingOut.value = false;
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Info', 'Fitur $feature akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }
}