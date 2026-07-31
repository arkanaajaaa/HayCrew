/// lib/controllers/CStorage/storage_home_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/constants/api_constant.dart';

/// Model item stok storage — field-nya mengikuti persis kolom tabel
/// `stoks` di backend (lihat StokController::index / Stok model), bukan
/// `nama`/`jumlah`/`satuan` seperti sebelumnya (field itu tidak pernah ada
/// di response API sehingga selalu tampil kosong/0).
class StokItemModel {
  final String id;
  final String jenis;
  final double beratPerItem;
  final int jumlahStok;
  final double estimasiTotalBerat;
  final String tanggalUpdate;
  final String status;
  final String? picName;

  const StokItemModel({
    required this.id,
    required this.jenis,
    required this.beratPerItem,
    required this.jumlahStok,
    required this.estimasiTotalBerat,
    required this.tanggalUpdate,
    required this.status,
    this.picName,
  });

  factory StokItemModel.fromJson(Map<String, dynamic> json) {
    return StokItemModel(
      id: json['id']?.toString() ?? '',
      jenis: json['jenis']?.toString() ?? '',
      beratPerItem: _toDouble(json['berat_per_item']),
      jumlahStok: _toInt(json['jumlah_stok']),
      estimasiTotalBerat: _toDouble(json['estimasi_total_berat']),
      tanggalUpdate: json['tanggal_update']?.toString() ?? '',
      status: json['status'] ?? 'aman',
      picName: json['user'] is Map ? json['user']['name']?.toString() : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
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

  final stokAyamGudang = 0.obs; 
  final stokKeluar = 0.obs; 

  int get totalItem => stokList.length;
  int get itemAman => stokList.where((s) => s.status == 'aman').length;
  int get itemWaspada => stokList.where((s) => s.status == 'waspada').length;
  int get itemTidakAman =>
      stokList.where((s) => s.status == 'tidak aman').length;

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

    final res = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/stok'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final list = _extractList(res.body);
      stokList.value = list.map((d) => StokItemModel.fromJson(d)).toList();
      // simpan cache lokal biar bisa dipakai offline nanti
      await _db.replaceAllStok(list);
    } else {
      await _loadStokFromLocal();
    }
  } catch (e) {
    debugPrint('Gagal ambil stok dari API, fallback lokal: $e');
    await _loadStokFromLocal();
  } finally {
    isLoading.value = false;
    }
  } 

  Future<void> _loadStokFromLocal() async {
    final localData = await _db.getAllStok();
    stokList.value = localData.map((d) => StokItemModel.fromJson(d)).toList();
  }

  Future<void> refreshData() async {
    await loadStok();
    await fetchStokAyamSummary();
  }

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

    await _fetchStokAyamFromLocal();
  }

  Future<Map<String, int>?> _fetchStokAyamFromApi() async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

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
      // jumlah_daging_jual kolomnya REAL (double) di SQLite, jadi harus
      // di-cast ke num dulu baru dibulatkan ke int — cast langsung ke
      // int? gagal karena tipe aslinya double, bukan int.
      (sum, item) =>
          sum + (((item['jumlah_daging_jual'] as num?)?.round()) ?? 0),
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
        title: Text(item.jenis),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Berat per Item : ${_formatBerat(item.beratPerItem)} kg'),
            const SizedBox(height: 8),
            Text('Jumlah Stok : ${item.jumlahStok} pcs'),
            const SizedBox(height: 8),
            Text(
              'Estimasi Total Berat : ${_formatBerat(item.estimasiTotalBerat)} kg',
            ),
            if (item.tanggalUpdate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tanggal Diperbaharui : ${item.tanggalUpdate}'),
            ],
            if ((item.picName ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('PIC : ${item.picName}'),
            ],
            const SizedBox(height: 8),
            Text('Status : ${_statusLabel(item.status)}'),
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
      ),
    );
  }

  // Format angka berat sama seperti di LaporanStokController: tanpa desimal
  // kalau bulat, satu desimal kalau tidak, dan pakai koma ala Indonesia.
  String _formatBerat(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aman':
        return '✅ Aman';
      case 'waspada':
        return '⚠️ Waspada';
      case 'tidak aman':
        return '❌ Tidak Aman';
      default:
        return status;
    }
  }
}