import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/status_permintaan_model.dart';
import '../services/google_calender_service.dart';
import '../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Controller untuk Home Page
/// Handles semua state dan logic untuk homepage
class HomeController extends GetxController {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  
  // Observable lists
  final RxList<StatusPermintaanModel> statusList = <StatusPermintaanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCalendarConnected = false.obs;
  final RxInt currentNavIndex = 0.obs;

  // User data dari arguments
  String? userName;
  String? userRole;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    
    // Ambil arguments dari route
    final args = Get.arguments as Map<String, dynamic>?;
    userName = args?['userName'] ?? 'User';
    userRole = args?['userRole'] ?? 'Karyawan';
    userId = args?['userId'];
    
    loadStatusPermintaan();
    checkCalendarConnection();
  }

  /// Check Google Calendar connection
  Future<void> checkCalendarConnection() async {
    isCalendarConnected.value = _calendarService.isSignedIn;
  }

  /// Connect to Google Calendar
  Future<void> connectGoogleCalendar() async {
    try {
      final success = await _calendarService.signIn();
      isCalendarConnected.value = success;
      
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Terhubung dengan Google Calendar',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal terhubung dengan Google Calendar',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  /// Disconnect from Google Calendar
  Future<void> disconnectGoogleCalendar() async {
    await _calendarService.signOut();
    isCalendarConnected.value = false;
    
    Get.snackbar(
      'Info',
      'Terputus dari Google Calendar',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  /// Load Status Permintaan dari API
  Future<void> loadStatusPermintaan() async {
    try {
      isLoading.value = true;

      // TODO: Ganti dengan actual API endpoint Anda
      // Contoh:
      // final response = await http.get(
      //   Uri.parse('YOUR_API_URL/status-permintaan'),
      //   headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = jsonDecode(response.body);
      //   statusList.value = data
      //       .map((item) => StatusPermintaanModel.fromJson(item))
      //       .toList();
      // }

      // Mock data untuk testing (hapus setelah connect ke API)
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = [
        {
          'id': '1',
          'day': 11,
          'month': 'Jan',
          'title': 'Dana pakan',
          'status': 'accepted',
          'created_at': DateTime.now().toIso8601String(),
          'description': 'Permintaan dana untuk pembelian pakan ayam',
        },
        {
          'id': '2',
          'day': 20,
          'month': 'Jan',
          'title': 'Beli sekam',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
          'description': 'Permintaan pembelian sekam untuk kandang',
        },
        {
          'id': '3',
          'day': 28,
          'month': 'Jan',
          'title': 'Pintu kandang',
          'subtitle': 'Lihat alasan',
          'status': 'rejected',
          'created_at': DateTime.now().toIso8601String(),
          'description': 'Dana tidak mencukupi untuk perbaikan pintu',
        },
      ];

      statusList.value = mockData
          .map((data) => StatusPermintaanModel.fromJson(data))
          .toList();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh semua data
  Future<void> refreshData() async {
    await loadStatusPermintaan();
  }

  /// Navigate to detail status permintaan
  void navigateToDetail(StatusPermintaanModel status) {
    // TODO: Buat halaman detail dan binding
    // Get.toNamed(
    //   AppRoutes.DETAIL_STATUS,
    //   arguments: {'status': status},
    // );
    
    // Untuk sementara, show dialog
    Get.dialog(
      AlertDialog(
        title: Text(status.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${status.day} ${status.month}'),
            const SizedBox(height: 8),
            Text('Status: ${_getStatusText(status.status)}'),
            if (status.description != null) ...[
              const SizedBox(height: 8),
              Text('Deskripsi: ${status.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Get status text
  String _getStatusText(StatusType type) {
    switch (type) {
      case StatusType.accepted:
        return 'Diterima';
      case StatusType.pending:
        return 'Pending';
      case StatusType.rejected:
        return 'Ditolak';
    }
  }

  /// Navigate to Lapor Kandang page
  void navigateToLaporKandang() {
    // TODO: Buat halaman dan binding untuk Lapor Kandang
    // Get.toNamed(AppRoutes.LAPOR_KANDANG);
    
    Get.snackbar(
      'Info',
      'Fitur Lapor Kandang akan segera tersedia',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }

  /// Navigate to Kirim Permintaan page
  void navigateToKirimPermintaan() {
    // TODO: Buat halaman dan binding untuk Kirim Permintaan
    // Get.toNamed(AppRoutes.KIRIM_PERMINTAAN);
    
    Get.snackbar(
      'Info',
      'Fitur Kirim Permintaan akan segera tersedia',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }

  /// Navigate to Notifications
  void navigateToNotifications() {
    // TODO: Buat halaman notifikasi
    // Get.toNamed(AppRoutes.NOTIFICATIONS);
    
    Get.snackbar(
      'Info',
      'Tidak ada notifikasi baru',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  /// Change bottom navigation index
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    
    // Navigate based on index
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Navigate to Riwayat
        // TODO: Buat halaman riwayat
        // Get.toNamed(AppRoutes.RIWAYAT);
        Get.snackbar('Info', 'Halaman Riwayat akan segera tersedia');
        // Reset to home
        currentNavIndex.value = 0;
        break;
      case 2:
        // Navigate to Profil
        // TODO: Buat halaman profil
        // Get.toNamed(AppRoutes.PROFIL);
        Get.snackbar('Info', 'Halaman Profil akan segera tersedia');
        // Reset to home
        currentNavIndex.value = 0;
        break;
    }
  }

  /// Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Clear user data
              Get.back();
              
              // Navigate to login
              Get.offAllNamed(AppRoutes.LOGIN);
              
              Get.snackbar(
                'Info',
                'Anda telah keluar',
                backgroundColor: Colors.blue[100],
                colorText: Colors.blue[900],
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(10),
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}