/// lib/controllers/CStorage/storage_home_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:haycrew_app/routes/app_routes.dart';

/// Model sederhana untuk item stok storage
class StokItemModel {
  final String id;
  final String nama;
  final int jumlah;
  final String satuan;
  final String status; // 'aman' | 'menipis' | 'habis'

  const StokItemModel({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.satuan,
    required this.status,
  });

  factory StokItemModel.fromJson(Map<String, dynamic> json) {
    return StokItemModel(
      id    : json['id']?.toString() ?? '',
      nama  : json['nama'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? '',
      status: json['status'] ?? 'aman',
    );
  }
}

class StorageHomeController extends GetxController {
  // ─── User Data ────────────────────────────────────────────────────────────
  final userName = 'User'.obs;
  final userRole = 'Karyawan Storage'.obs;
  final userId   = ''.obs;

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<StokItemModel> stokList = <StokItemModel>[].obs;
  final isLoading = false.obs;

  // ─── Summary stats (dihitung dari stokList) ───────────────────────────────
  int get totalItem   => stokList.length;
  int get itemAman    => stokList.where((s) => s.status == 'aman').length;
  int get itemMenipis => stokList.where((s) => s.status == 'menipis').length;
  int get itemHabis   => stokList.where((s) => s.status == 'habis').length;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    loadStok();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    userName.value = args['userName'] ?? 'User';
    userRole.value = args['userRole'] ?? 'Karyawan Storage';
    userId.value   = args['userId']   ?? '';
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> loadStok() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Ganti dengan actual API call
      // final response = await http.get(
      //   Uri.parse('YOUR_API/storage/stok?userId=${userId.value}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      final mockData = [
        {'id': '1', 'nama': 'Pakan Ayam',    'jumlah': 150, 'satuan': 'kg',   'status': 'aman'},
        {'id': '2', 'nama': 'Sekam',         'jumlah': 20,  'satuan': 'karung','status': 'menipis'},
        {'id': '3', 'nama': 'Vitamin Ternak','jumlah': 0,   'satuan': 'botol','status': 'habis'},
        {'id': '4', 'nama': 'Obat Semprot',  'jumlah': 8,   'satuan': 'liter','status': 'aman'},
        {'id': '5', 'nama': 'Tali Rafia',    'jumlah': 3,   'satuan': 'gulung','status': 'menipis'},
      ];

      stokList.value = mockData.map((d) => StokItemModel.fromJson(d)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat stok: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async => await loadStok();

  // ─── Routing ──────────────────────────────────────────────────────────────

  void navigateToNotifications() {
    Get.snackbar('Info', 'Fitur Notifikasi akan segera tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        margin: const EdgeInsets.all(15));
  }

  void navigateToTambahStok() {
    Get.snackbar('Info', 'Fitur Tambah Stok akan segera tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        margin: const EdgeInsets.all(15));
  }

  void navigateToLaporanStok() {
    Get.snackbar('Info', 'Fitur Laporan Stok akan segera tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        margin: const EdgeInsets.all(15));
  }

  void navigateToDetail(StokItemModel item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(item.nama),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah : ${item.jumlah} ${item.satuan}'),
            const SizedBox(height: 8),
            Text('Status : ${_statusLabel(item.status)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('OK')),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aman':    return '✅ Aman';
      case 'menipis': return '⚠️ Menipis';
      case 'habis':   return '❌ Habis';
      default:        return status;
    }
  }
}