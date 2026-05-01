import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/navbar_controller.dart';
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
  // ─── User Data ────────────────────────────────────────────────────────────
  final userName = 'Haerudin'.obs;
  final userRole = 'Senior Agricultural Specialist'.obs;
  final joinDate = 'Karyawan sejak 12-02-2023'.obs;
  final isActive = true.obs;

  // ─── Computed Getters — semua pakai AppColors ─────────────────────────────

  String get statusLabel   => isActive.value ? 'Aktif' : 'Nonaktif';
  Color  get statusColor   => isActive.value ? AppColors.primaryGreen : AppColors.red;
  Color  get statusBgColor => isActive.value
      ? AppColors.lightGreen.withOpacity(0.15)
      : AppColors.red.withOpacity(0.1);

  List<ProfilMenuItem> get menuItems => [
        ProfilMenuItem(
          icon:        Icons.person_outline,
          iconBgColor: AppColors.calendarBackground,
          iconColor:   AppColors.textDark,
          title:       'Informasi Pribadi',
          onTap:       onTapInformasiPribadi,
        ),
        ProfilMenuItem(
          icon:        Icons.settings_outlined,
          iconBgColor: AppColors.calendarBackground,
          iconColor:   AppColors.textDark,
          title:       'Pengaturan Akun',
          onTap:       onTapPengaturanAkun,
        ),
        ProfilMenuItem(
          icon:        Icons.history,
          iconBgColor: AppColors.calendarBackground,
          iconColor:   AppColors.orange,
          title:       'Riwayat Aktivitas',
          onTap:       onTapRiwayatAktivitas,
        ),
        ProfilMenuItem(
          icon:        Icons.security_outlined,
          iconBgColor: AppColors.calendarBackground,
          iconColor:   AppColors.lightGreen,
          title:       'Keamanan',
          onTap:       onTapKeamanan,
        ),
        ProfilMenuItem(
          icon:        Icons.help_outline,
          iconBgColor: AppColors.calendarBackground,
          iconColor:   AppColors.primaryGreen,
          title:       'Pusat Bantuan',
          onTap:       onTapPusatBantuan,
        ),
        ProfilMenuItem(
          icon:        Icons.logout,
          iconBgColor: AppColors.red.withOpacity(0.1),
          iconColor:   AppColors.red,
          title:       'Keluar',
          onTap:       onTapKeluar,
          isDanger:    true,
        ),
      ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // Ambil data user dari arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['userName'] != null) userName.value = args['userName'];
      if (args['userRole'] != null) userRole.value = args['userRole'];
    }

    // Sync highlight navbar ke index 2 (Profil)
    // NavbarController sudah ada karena di-register permanent di HomeBinding
    Get.find<NavbarController>().currentNavIndex.value = 2;
  }

  @override
  void onClose() {
    // Saat keluar dari ProfilPage via back button, kembalikan highlight ke 0
    // hanya jika tujuan kembali adalah Home
    if (Get.find<NavbarController>().currentNavIndex.value == 2) {
      Get.find<NavbarController>().currentNavIndex.value = 0;
    }
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void onTapInformasiPribadi() => _showComingSoon('Informasi Pribadi');
  void onTapPengaturanAkun()   => _showComingSoon('Pengaturan Akun');
  void onTapRiwayatAktivitas() => _showComingSoon('Riwayat Aktivitas');
  void onTapKeamanan()         => _showComingSoon('Keamanan');
  void onTapPusatBantuan()     => _showComingSoon('Pusat Bantuan');

  void onTapKeluar() {
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

  // ─── Private ──────────────────────────────────────────────────────────────

  void _doLogout() {
    Get.back();
    // TODO: hapus session / token
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Info', 'Fitur $feature akan segera tersedia',
      snackPosition:   SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText:       Colors.blue[900],
      margin:          const EdgeInsets.all(15),
      duration:        const Duration(seconds: 2),
    );
  }
}