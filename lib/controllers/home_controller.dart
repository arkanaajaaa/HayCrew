import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/status_permintaan_model.dart';
import '../services/google_calender_service.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeController extends GetxController {
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  final RxList<StatusPermintaanModel> statusList = <StatusPermintaanModel>[].obs;
  final RxBool isLoading           = false.obs;
  final RxBool isCalendarConnected = false.obs;

  String? userName;
  String? userRole;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    userName = args?['userName'] ?? 'User';
    userRole = args?['userRole'] ?? 'Karyawan';
    userId   = args?['userId'];
    loadStatusPermintaan();
    checkCalendarConnection();
  }

  // ─── Service & Data ───────────────────────────────────────────────────────

  Future<void> checkCalendarConnection() async {
    isCalendarConnected.value = _calendarService.isSignedIn;
  }

  Future<void> loadStatusPermintaan() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Ganti dengan actual API call
      final mockData = [
        {
          'id': '1', 'day': 11, 'month': 'Jan',
          'title': 'Dana pakan', 'status': 'accepted',
          'description': 'Permintaan dana untuk pembelian pakan ayam',
        },
        {
          'id': '2', 'day': 20, 'month': 'Jan',
          'title': 'Beli sekam', 'status': 'pending',
          'description': 'Permintaan pembelian sekam untuk kandang',
        },
        {
          'id': '3', 'day': 28, 'month': 'Jan',
          'title': 'Pintu kandang', 'status': 'rejected',
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

  // ─── Routing ──────────────────────────────────────────────────────────────

  void navigateToNotifications() {
    Get.snackbar(
      'Info', 'Fitur Notifikasi akan segera tersedia',
      snackPosition:   SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      margin:          const EdgeInsets.all(15),
    );
  }

  void navigateToLaporKandang()    => Get.toNamed(AppRoutes.LAPOR_KANDANG);
  void navigateToKirimPermintaan() => Get.toNamed(AppRoutes.KIRIM_PERMINTAAN);

  void navigateToDetail(StatusPermintaanModel status) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(status.title),
        content: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${status.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(status.description ?? 'Tidak ada deskripsi'),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('OK')),
        ],
      ),
    );
  }
}