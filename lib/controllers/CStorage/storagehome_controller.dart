/// lib/controllers/CStorage/storage_home_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/constants/api_constant.dart';

/// Model sederhana untuk item stok storage
class StokItemModel {
  final String id;
  final String nama;
  final int jumlah;
  final String satuan;
  final String status;

  const StokItemModel({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.satuan,
    required this.status,
  });

  factory StokItemModel.fromJson(Map<String, dynamic> json) {
    return StokItemModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? '',
      status: json['status'] ?? 'aman',
    );
  }
}

class StorageHomeController extends GetxController {
  final _db = DBHelper();
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final userName = 'User'.obs;
  final userRole = 'Karyawan Storage'.obs;
  final userId = ''.obs;

  final RxList<StokItemModel> stokList = <StokItemModel>[].obs;
  final isLoading = false.obs;

  // ✨ Ringkasan stok ayam — coba ambil dari VPS dulu, fallback ke data lokal
  final stokAyamGudang = 0.obs; // ekor ayam yang masih ada di gudang
  final stokKeluar = 0.obs; // total ekor yang sudah keluar/terjual

  int get totalItem => stokList.length;
  int get itemAman => stokList.where((s) => s.status == 'aman').length;
  int get itemMenipis => stokList.where((s) => s.status == 'menipis').length;
  int get itemHabis => stokList.where((s) => s.status == 'habis').length;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    loadStok();
    fetchStokAyamSummary();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    userName.value = args['userName'] ?? 'User';
    userRole.value = args['userRole'] ?? 'Karyawan Storage';
    userId.value = args['userId'] ?? '';
  }

  Future<void> loadStok() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      final mockData = [
        {
          'id': '1',
          'nama': 'Pakan Ayam',
          'jumlah': 150,
          'satuan': 'kg',
          'status': 'aman',
        },
        {
          'id': '2',
          'nama': 'Sekam',
          'jumlah': 20,
          'satuan': 'karung',
          'status': 'menipis',
        },
        {
          'id': '3',
          'nama': 'Vitamin Ternak',
          'jumlah': 0,
          'satuan': 'botol',
          'status': 'habis',
        },
        {
          'id': '4',
          'nama': 'Obat Semprot',
          'jumlah': 8,
          'satuan': 'liter',
          'status': 'aman',
        },
        {
          'id': '5',
          'nama': 'Tali Rafia',
          'jumlah': 3,
          'satuan': 'gulung',
          'status': 'menipis',
        },
      ];

      stokList.value = mockData.map((d) => StokItemModel.fromJson(d)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat stok: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadStok();
    await fetchStokAyamSummary();
  }

  /// Hitung ringkasan stok ayam:
  /// 1) Coba ambil dari VPS dulu (GET /api/laporan-gudang & GET /api/permintaan)
  /// 2) Kalau gagal/offline, fallback ke data lokal (SQLite)
  Future<void> fetchStokAyamSummary() async {
    try {
      final fromApi = await _fetchStokAyamFromApi();
      if (fromApi != null) {
        stokKeluar.value = fromApi['keluar']!;
        stokAyamGudang.value = fromApi['gudang']!;
        return;
      }
    } catch (e) {
      debugPrint('Gagal ambil ringkasan stok ayam dari API: $e');
    }

    // Fallback: hitung dari data lokal
    await _fetchStokAyamFromLocal();
  }

  /// Ambil data dari VPS. Return null kalau request gagal (biar fallback jalan).
  ///
  /// CATATAN: sesuaikan parsing di bawah ini kalau bentuk response JSON dari
  /// Laravel-mu beda (misal dibungkus {"data": [...]} atau field-nya beda nama).
  Future<Map<String, int>?> _fetchStokAyamFromApi() async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    // 1) Total KELUAR — dari GET /api/laporan-gudang
    final laporanRes = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/laporan-gudang'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (laporanRes.statusCode != 200) return null;
    final laporanList = _extractList(laporanRes.body);

    final totalKeluar = laporanList.fold<int>(0, (sum, item) {
      final v = item['jumlah_daging_jual'];
      return sum + (v is int ? v : int.tryParse(v.toString()) ?? 0);
    });

    // 2) Total MASUK — dari GET /api/permintaan, difilter yang tipe/nama-nya
    //    cocok dengan yang dikirim TambahStokController.
    final permintaanRes = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/permintaan'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (permintaanRes.statusCode != 200) return null;
    final permintaanList = _extractList(permintaanRes.body);

    final totalMasuk = permintaanList
        .where((item) => item['nama_permintaan'] == 'Tambah Stok Ayam')
        .fold<int>(0, (sum, item) {
          final v = item['jumlah'];
          return sum + (v is int ? v : int.tryParse(v.toString()) ?? 0);
        });

    final gudang = (totalMasuk - totalKeluar) < 0 ? 0 : (totalMasuk - totalKeluar);
    return {'gudang': gudang, 'keluar': totalKeluar};
  }

  /// Response Laravel biasanya berupa List langsung, atau dibungkus
  /// {"data": [...]}. Coba tangani dua-duanya.
  List<Map<String, dynamic>> _extractList(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _fetchStokAyamFromLocal() async {
    final tambahList = await _db.getAllTambahStok();
    final laporanList = await _db.getAllLaporanGudang();

    final totalMasuk = tambahList.fold<int>(
      0,
      (sum, item) => sum + ((item['stok_masuk'] as int?) ?? 0),
    );
    final totalKeluar = laporanList.fold<int>(
      0,
      (sum, item) => sum + ((item['jumlah_daging_jual'] as int?) ?? 0),
    );

    stokKeluar.value = totalKeluar;
    stokAyamGudang.value =
        (totalMasuk - totalKeluar) < 0 ? 0 : (totalMasuk - totalKeluar);
  }

  void navigateToNotifications() {
    Get.snackbar(
      'Info',
      'Fitur Notifikasi akan segera tersedia',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[100],
      margin: const EdgeInsets.all(15),
    );
  }

  void navigateToTambahStok() {
    Get.toNamed(AppRoutes.TAMBAH_STOK);
  }

  void navigateToLaporanStok() {
    Get.toNamed(AppRoutes.LAPORAN_STOK);
  }

  void navigateToProfil() {
    Get.toNamed(
      AppRoutes.PROFIL,
      arguments: {'userName': userName.value, 'userRole': userRole.value},
    );
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
        actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aman':
        return '✅ Aman';
      case 'menipis':
        return '⚠️ Menipis';
      case 'habis':
        return '❌ Habis';
      default:
        return status;
    }
  }
}