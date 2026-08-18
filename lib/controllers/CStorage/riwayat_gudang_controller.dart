import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/models/riwayat_item_model.dart';
import 'package:haycrew_app/services/dbService.dart';

/// Riwayat aktivitas gudang milik user yang login — gabungan laporan gudang
/// (`/api/laporan-gudang`, sudah difilter per user_id di backend) dan
/// submission tambah stok (disimpan sebagai `permintaan` tipe barang dengan
/// nama "Tambah Stok Ayam", sama seperti yang dipakai StorageHomeController
/// buat ringkasan stok ayam). Beda dari sebelumnya yang nampilin `/api/stok`
/// (stok gabungan SEMUA karyawan gudang, bukan riwayat milik user ini).
class RiwayatGudangController extends GetxController {
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
    List<RiwayatItem> laporanGudang = [];
    List<RiwayatItem> tambahStok = [];

    try {
      laporanGudang = await _fetchLaporanGudang();
    } catch (_) {
      anyFailure = true;
    }
    try {
      tambahStok = await _fetchTambahStok();
    } catch (_) {
      anyFailure = true;
    }

    final pendingLocal = await _pendingLocal();

    final merged = [...laporanGudang, ...tambahStok, ...pendingLocal]
      ..sort((a, b) => b.date.compareTo(a.date));

    items.assignAll(merged);
    hasError.value = anyFailure && items.isEmpty;
    isLoading.value = false;
  }

  Future<List<RiwayatItem>> _fetchLaporanGudang() async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}/api/laporan-gudang'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['data'] as List?) ?? [];

    return list.map<RiwayatItem>((item) {
      final items = (item['items'] as List?) ?? [];
      final jumlahJenis = items.length;
      return RiwayatItem(
        id: 'laporan-gudang-${item['id']}',
        type: RiwayatType.laporanGudang,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Laporan Gudang',
        subtitle:
            '${item['tempat_pendistribusian'] ?? '-'} • $jumlahJenis jenis stok daging',
        statusLabel: 'Terkirim',
        statusColor: AppColors.primaryGreen,
      );
    }).toList();
  }

  Future<List<RiwayatItem>> _fetchTambahStok() async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}/api/permintaan'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['data'] as List?) ?? [];

    return list
        .where((item) => item['nama_permintaan'] == 'Tambah Stok Ayam')
        .map<RiwayatItem>((item) {
      return RiwayatItem(
        id: 'tambah-stok-${item['id']}',
        type: RiwayatType.tambahStok,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Tambah Stok',
        subtitle:
            '${item['jumlah'] ?? '-'} ekor • ${item['tempat_pendistribusian'] ?? '-'}',
        statusLabel: 'Terkirim',
        statusColor: AppColors.primaryGreen,
      );
    }).toList();
  }

  Future<List<RiwayatItem>> _pendingLocal() async {
    final unsyncedLaporan = await _db.getUnsyncedLaporanGudang();
    final unsyncedTambah = await _db.getUnsyncedTambahStok();

    final laporanItems = unsyncedLaporan.map((item) {
      return RiwayatItem(
        id: 'laporan-gudang-local-${item['id']}',
        type: RiwayatType.laporanGudang,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Laporan Gudang',
        subtitle: '${item['tempat_pendistribusian'] ?? '-'}',
        statusLabel: 'Tersimpan Lokal',
        statusColor: Colors.orange,
        isPending: true,
      );
    });

    final tambahItems = unsyncedTambah.map((item) {
      return RiwayatItem(
        id: 'tambah-stok-local-${item['id']}',
        type: RiwayatType.tambahStok,
        date: DateTime.tryParse(item['tanggal']?.toString() ?? '') ?? DateTime.now(),
        title: 'Tambah Stok',
        subtitle:
            '${item['stok_masuk'] ?? '-'} ekor • ${item['tempat_pendistribusian'] ?? '-'}',
        statusLabel: 'Tersimpan Lokal',
        statusColor: Colors.orange,
        isPending: true,
      );
    });

    return [...laporanItems, ...tambahItems];
  }
}
