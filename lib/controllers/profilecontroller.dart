import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/constants/api_constant.dart';
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
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  // ─── Static precomputed colors ────────────────────────────────────────────
  static final _activeBgColor   = AppColors.lightGreen.withOpacity(0.15);
  static final _inactiveBgColor = AppColors.red.withOpacity(0.1);
  static final _logoutBgColor   = AppColors.red.withOpacity(0.1);

  // ─── User Data — prefill instan dari args login, lalu ditimpa data asli
  // dari /api/profile begitu selesai fetch (lihat fetchProfile()) ───────────
  final userName = 'User'.obs;
  final userRole = 'Karyawan'.obs;
  final userPhotoUrl = Rxn<String>();
  final userEmail = Rxn<String>();
  final userPhone = Rxn<String>();

  // Detail karyawan (opsional — null kalau user ini belum punya data
  // karyawan tersimpan, misalnya akun admin)
  final tempatLahir = Rxn<String>();
  final tanggalLahir = Rxn<String>();
  final jenisKelamin = Rxn<String>();

  final joinDate = Rxn<String>();
  final isActive = true.obs;
  final isLoggingOut = false.obs;

  final isLoadingProfile = false.obs;
  final hasProfileError = false.obs;

  late final List<ProfilMenuItem> menuItems;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    menuItems = _buildMenuItems();
    fetchProfile();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userName.value = args['userName'] ?? 'User';
      userRole.value = args['userRole'] ?? 'Karyawan';
      userPhotoUrl.value = args['userPhotoUrl'] as String?;
    }
  }

  /// Fetch data profil asli dari server — dipanggil sendiri di sini, nggak
  /// nunggu/nebeng arguments navigasi (yang kadang nggak ke-pass di
  /// beberapa alur redirect), jadi profil selalu bisa reload dirinya
  /// sendiri kapanpun halaman ini dibuka.
  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    hasProfileError.value = false;
    try {
      final res = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/api/profile'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final user = jsonDecode(res.body)['user'] as Map<String, dynamic>;
        userName.value = user['name'] ?? userName.value;
        userEmail.value = user['email'] as String?;
        userPhotoUrl.value = user['foto_url'] as String?;
        userPhone.value = user['no_hp'] as String?;

        final karyawan = user['karyawan'] as Map<String, dynamic>?;
        if (karyawan != null) {
          isActive.value = karyawan['status'] == 'aktif';
          tempatLahir.value = karyawan['tempat_lahir'] as String?;
          jenisKelamin.value = karyawan['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan';
          final lahir = DateTime.tryParse(karyawan['tanggal_lahir']?.toString() ?? '');
          tanggalLahir.value = lahir != null ? DateFormat('dd MMM yyyy', 'id_ID').format(lahir) : null;
          final bergabung = DateTime.tryParse(karyawan['tanggal_bergabung']?.toString() ?? '');
          joinDate.value = bergabung != null
              ? 'Karyawan sejak ${DateFormat('dd MMM yyyy', 'id_ID').format(bergabung)}'
              : null;
        }
      } else {
        hasProfileError.value = true;
      }
    } catch (_) {
      hasProfileError.value = true;
    } finally {
      isLoadingProfile.value = false;
    }
  }


  String get statusLabel   => isActive.value ? 'Aktif' : 'Nonaktif';
  Color  get statusColor   => isActive.value ? AppColors.primaryGreen : AppColors.red;
  Color  get statusBgColor => isActive.value ? _activeBgColor : _inactiveBgColor;


  List<ProfilMenuItem> _buildMenuItems() => [
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


  void onTapRiwayatAktivitas() {
    // Riwayat itu tab index 1 di kedua shell (kandang & gudang) — pindah tab
    // di shell yang sama, bukan push route baru, biar nggak ada instance
    // duplikat dan tombol back nggak ambigu (riwayat cuma pernah dibuka
    // sebagai tab, nggak pernah sebagai halaman ter-push).
    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().changeTab(1);
    }
  }


  Future<void> onTapPusatBantuan() async {
    const waUrl = 'https://wa.me/6281274734090'; 
    final uri = Uri.parse(waUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, 
        );
      } else {
        _showErrorSnackbar('Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan saat membuka tautan');
    }
  }

  void onTapKeluar() {
    if (isLoggingOut.value) return; 
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

  Future<void> _doLogout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;

    Get.back(); 

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
    } catch (_) {}

    await _storage.erase();
    Get.offAllNamed(AppRoutes.LOGIN);

    isLoggingOut.value = false;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Gagal', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }
}