import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/models/riwayat_item_model.dart';
import 'package:haycrew_app/services/dbService.dart';

/// Riwayat aktivitas kandang milik user yang login — gabungan permintaan
/// dana/barang (`/api/permintaan`) dan laporan kandang mingguan
/// (`/api/laporan-kandang`). Dua-duanya sudah difilter per user_id di
/// backend, jadi tinggal digabung & diurutkan di sini.
class RiwayatKandangController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';
  final _db = DBHelper();

  final isLoading = false.obs;
  final hasError = false.obs;
  final items = <RiwayatItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    hasError.value = false;

    bool anyFailure = false;
    List<RiwayatItem> permintaan = [];
    List<RiwayatItem> laporan = [];

    try {
      permintaan = await _fetchPermintaan();
    } catch (_) {
      anyFailure = true;
    }
    try {
      laporan = await _fetchLaporanKandang();
    } catch (_) {
      anyFailure = true;
    }

    final pendingLocal = await _pendingLaporanLocal();

    final merged = [...permintaan, ...laporan, ...pendingLocal]
      ..sort((a, b) => b.date.compareTo(a.date));

    items.assignAll(merged);
    hasError.value = anyFailure && items.isEmpty;
    isLoading.value = false;
  }

  Future<List<RiwayatItem>> _fetchPermintaan() async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}/api/permintaan'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['data'] as List?) ?? [];

    return list.map<RiwayatItem>((item) {
      final status = (item['status'] ?? 'pending').toString();
      final tipe = (item['tipe'] ?? 'barang').toString();
      final nominal = tipe == 'dana'
          ? 'Rp ${NumberFormat.decimalPattern('id_ID').format(num.tryParse(item['harga']?.toString() ?? '') ?? 0)}'
          : '${item['jumlah'] ?? 0} pcs';

      return RiwayatItem(
        id: 'permintaan-${item['id']}',
        type: RiwayatType.permintaan,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: item['nama_permintaan']?.toString() ?? 'Permintaan',
        subtitle: nominal,
        statusLabel: _permintaanStatusLabel(status),
        statusColor: _permintaanStatusColor(status),
        // ambil alasan penolakan dari payload jika tersedia
        alasan: item['alasan_tolak']?.toString(),
      );
    }).toList();
  }

  Future<List<RiwayatItem>> _fetchLaporanKandang() async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}/api/laporan-kandang'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['data'] as List?) ?? [];

    return list.map<RiwayatItem>((item) {
      return RiwayatItem(
        id: 'laporan-${item['id']}',
        type: RiwayatType.laporanKandang,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Laporan Kandang',
        subtitle:
            'Ayam mati: ${item['jumlah_ayam_mati'] ?? '-'} • Bobot: ${item['rata_rata_bobot'] ?? '-'} gram',
        statusLabel: 'Terkirim',
        statusColor: AppColors.primaryGreen,
      );
    }).toList();
  }

  Future<List<RiwayatItem>> _pendingLaporanLocal() async {
    final unsynced = await _db.getUnsyncedLaporan();
    return unsynced.map((item) {
      return RiwayatItem(
        id: 'laporan-local-${item['id']}',
        type: RiwayatType.laporanKandang,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Laporan Kandang',
        subtitle:
            'Ayam mati: ${item['jumlah_ayam_mati'] ?? '-'} • Bobot: ${item['rata_rata_bobot'] ?? '-'} gram',
        statusLabel: 'Tersimpan Lokal',
        statusColor: Colors.orange,
        isPending: true,
      );
    }).toList();
  }

  String _permintaanStatusLabel(String status) {
    switch (status) {
      case 'disetujui':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Color _permintaanStatusColor(String status) {
    switch (status) {
      case 'disetujui':
        return AppColors.primaryGreen;
      case 'ditolak':
        return AppColors.red;
      default:
        return Colors.orange;
    }
  }
}