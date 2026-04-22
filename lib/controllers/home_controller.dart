import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/status_permintaan_model.dart';
import '../services/google_calender_service.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Controller untuk Home Page
class HomeController extends GetxController {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  
  // Observable states
  final RxList<StatusPermintaanModel> statusList = <StatusPermintaanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCalendarConnected = false.obs;
  final RxInt currentNavIndex = 0.obs; // Index untuk Reusable Navbar

  // User data
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

  // --- Navigasi & UI Logic ---

  /// Mengubah index navigasi bawah (Digunakan oleh CBottomNav)
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    
    switch (index) {
      case 0:
        // Tetap di Home/Beranda
        break;
      case 1:
        // Navigasi ke Riwayat jika sudah ada routenya
        // Get.toNamed(AppRoutes.RIWAYAT); 
        _showUnderDevelopmentSnackbar('Riwayat');
        break;
      case 2:
        // Navigasi ke Profil jika sudah ada routenya
        // Get.toNamed(AppRoutes.PROFIL);
        _showUnderDevelopmentSnackbar('Profil');
        break;
    }
  }

  void _showUnderDevelopmentSnackbar(String feature) {
    Get.snackbar(
      'Info',
      'Fitur $feature akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      margin: const EdgeInsets.all(15),
    );
    // Kembalikan highlight ke Beranda karena halaman belum pindah
    currentNavIndex.value = 0;
  }

  // --- Service & Data Logic ---

  Future<void> checkCalendarConnection() async {
    isCalendarConnected.value = _calendarService.isSignedIn;
  }

  Future<void> loadStatusPermintaan() async {
    try {
      isLoading.value = true;
      
      // Simulasi delay API
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = [
        {
          'id': '1',
          'day': 11,
          'month': 'Jan',
          'title': 'Dana pakan',
          'status': 'accepted',
          'description': 'Permintaan dana untuk pembelian pakan ayam',
        },
        {
          'id': '2',
          'day': 20,
          'month': 'Jan',
          'title': 'Beli sekam',
          'status': 'pending',
          'description': 'Permintaan pembelian sekam untuk kandang',
        },
        {
          'id': '3',
          'day': 28,
          'month': 'Jan',
          'title': 'Pintu kandang',
          'status': 'rejected',
          'description': 'Dana tidak mencukupi untuk perbaikan pintu',
        },
      ];

      statusList.value = mockData
          .map((data) => StatusPermintaanModel.fromJson(data))
          .toList();

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async => await loadStatusPermintaan();

  // --- Routing Methods ---

  void navigateToNotifications() => _showUnderDevelopmentSnackbar('Notifikasi');
  
  void navigateToLaporKandang() {
    // Get.toNamed(AppRoutes.LAPOR_KANDANG);
    Get.toNamed(AppRoutes.LAPOR_KANDANG);
  }

  void navigateToKirimPermintaan() {
    // Get.toNamed(AppRoutes.KIRIM_PERMINTAAN);
    _showUnderDevelopmentSnackbar('Kirim Permintaan');
  }

  void navigateToDetail(StatusPermintaanModel status) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(status.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${status.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(status.description ?? 'Tidak ada deskripsi'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}