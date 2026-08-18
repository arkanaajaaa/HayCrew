/// lib/controllers/CStorage/storage_home_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/services/gudang_service.dart';
import 'package:haycrew_app/constants/api_constant.dart';

/// Model item stok storage — field-nya mengikuti persis kolom tabel
/// `stoks` di backend (lihat StokController::index / Stok model), bukan
/// `nama`/`jumlah`/`satuan` seperti sebelumnya (field itu tidak pernah ada
/// di response API sehingga selalu tampil kosong/0).
class StokItemModel {
  final String id;
  final String jenis;
  final String? gudang;
  final double beratPerItem;
  final int jumlahStok;
  final double estimasiTotalBerat;
  final String tanggalUpdate;
  final String status;
  final String? picName;

  const StokItemModel({
    required this.id,
    required this.jenis,
    this.gudang,
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
      gudang: json['gudang']?.toString(),
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
  String get token => _token;

  final userName = 'User'.obs;
  final userRole = 'Karyawan Storage'.obs;
  final userId = ''.obs;

  final RxList<StokItemModel> stokList = <StokItemModel>[].obs;
  final isLoading = false.obs;
  // true kalau fetch gagal DAN cache lokal juga kosong — beda dari
  // "genuinely gak ada stok", biar gak nyamar jadi empty state biasa.
  final hasLoadError = false.obs;

  final stokAyamGudang = 0.obs;
  final stokKeluar = 0.obs;

  // Filter lokasi gudang (Bogor/Depok/dst) — "Semua Gudang" berarti gabungan
  // semua lokasi seperti sebelumnya. Data mentahnya (unfiltered) disimpan
  // terpisah biar ganti filter nggak perlu fetch ulang ke server.
  static const String semuaGudang = 'Semua Gudang';
  final selectedGudang = semuaGudang.obs;
  final gudangFilterOptions = <String>[semuaGudang].obs;

  List<StokItemModel> _allStok = [];
  List<Map<String, dynamic>> _rawTambahStokMasuk = [];
  List<Map<String, dynamic>> _rawPesananKeluar = [];

  int get totalItem => stokList.length;
  int get itemAman => stokList.where((s) => s.status == 'aman').length;
  int get itemWaspada => stokList.where((s) => s.status == 'waspada').length;
  int get itemTidakAman =>
      stokList.where((s) => s.status == 'tidak aman').length;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    _initialLoad();
    // Polling-nya dijalankan satu timer bersama di HomePageStorage (biar
    // nyatu sama refresh CalendarWidget), bukan timer sendiri di sini —
    // sama seperti pola di HomeController (kandang).
  }

  Future<void> _initialLoad() async {
    await loadStok();
    // fetchStokAyamSummary butuh _allStok (buat resolve gudang tiap item
    // pesanan lewat stok_id), jadi ditunggu setelah loadStok kelar biar
    // urutannya konsisten baik pas online maupun lagi retry dari cache.
    await fetchStokAyamSummary();
    await _loadGudangFilterOptions();
  }

  Future<void> _loadGudangFilterOptions() async {
    final names = await GudangService.fetchGudangNames(_token);
    gudangFilterOptions.assignAll([semuaGudang, ...names]);
  }

  void setGudangFilter(String value) {
    if (selectedGudang.value == value) return;
    selectedGudang.value = value;
    _applyStokFilter();
    _applySummaryFilter();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    userName.value = args['userName'] ?? 'User';
    userRole.value = args['userRole'] ?? 'Karyawan Storage';
    userId.value = args['userId'] ?? '';
  }

  Future<void> loadStok({bool showLoading = true}) async {
  try {
    if (showLoading) isLoading.value = true;
    hasLoadError.value = false;

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
      _allStok = list.map((d) => StokItemModel.fromJson(d)).toList();
      _applyStokFilter();
      // simpan cache lokal biar bisa dipakai offline nanti
      await _db.replaceAllStok(list);
    } else {
      await _loadStokFromLocal();
      if (_allStok.isEmpty) hasLoadError.value = true;
    }
  } catch (e) {
    debugPrint('Gagal ambil stok dari API, fallback lokal: $e');
    await _loadStokFromLocal();
    if (_allStok.isEmpty) hasLoadError.value = true;
  } finally {
    isLoading.value = false;
    }
  }

  Future<void> _loadStokFromLocal() async {
    final localData = await _db.getAllStok();
    _allStok = localData.map((d) => StokItemModel.fromJson(d)).toList();
    _applyStokFilter();
  }

  void _applyStokFilter() {
    final filtered = selectedGudang.value == semuaGudang
        ? _allStok
        : _allStok.where((s) => s.gudang == selectedGudang.value).toList();
    stokList.value = _sortBySeverity(List.of(filtered));
  }

  /// Urutin stok yang paling butuh perhatian ke atas (tidak aman → waspada
  /// → aman) — lebih berguna buat karyawan gudang yang butuh tahu "apa yang
  /// harus ditangani sekarang" ketimbang urutan tanggal update mentah dari
  /// server.
  List<StokItemModel> _sortBySeverity(List<StokItemModel> list) {
    int severity(String status) {
      switch (status) {
        case 'tidak aman':
          return 0;
        case 'waspada':
          return 1;
        default:
          return 2;
      }
    }

    list.sort((a, b) => severity(a.status).compareTo(severity(b.status)));
    return list;
  }

  Future<void> refreshData({bool showLoading = true}) async {
    await loadStok(showLoading: showLoading);
    await fetchStokAyamSummary();
  }

  Future<void> fetchStokAyamSummary() async {
    try {
      final fromApi = await _fetchStokAyamFromApi();
      if (fromApi) {
        _applySummaryFilter();
        return;
      }
    } catch (e) {
      debugPrint('Gagal ambil ringkasan stok ayam dari API: $e');
    }

    await _fetchStokAyamFromLocal();
  }

  /// Ambil data mentah pemasukan (tambah stok) & pengeluaran (pesanan), lalu
  /// simpan di `_rawTambahStokMasuk`/`_rawPesananKeluar` — dua-duanya sudah
  /// dikasih tag `gudang` per baris biar bisa difilter ulang di
  /// `_applySummaryFilter()` tanpa fetch API lagi tiap ganti filter lokasi.
  Future<bool> _fetchStokAyamFromApi() async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    // Stok Keluar diambil dari pesanan (yang beneran motong `jumlah_stok` di
    // tabel stoks — lihat PesananController::potongStokUntukItem), bukan
    // dari `jumlah_daging_jual` laporan gudang (angka self-report yang
    // nggak nyambung ke stok yang beneran berkurang).
    final pesananRes = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/pesanan'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (pesananRes.statusCode != 200) return false;
    final pesananList = _extractList(pesananRes.body);

    // Pesanan sendiri nggak punya field gudang langsung — tiap item-nya
    // nunjuk ke stok_id, dan gudang-nya diambil dari situ (`_allStok` yang
    // baru difetch di loadStok()).
    final stokGudangById = {for (final s in _allStok) s.id: s.gudang};

    _rawPesananKeluar = pesananList.expand((pesanan) {
      final items = (pesanan['items'] as List?) ?? [];
      return items.map((item) => {
            'kuantitas': item['kuantitas'],
            'gudang': stokGudangById[item['stok_id']?.toString()],
          });
    }).toList();

    final permintaanRes = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/permintaan'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (permintaanRes.statusCode != 200) return false;
    final permintaanList = _extractList(permintaanRes.body);

    _rawTambahStokMasuk = permintaanList
        .where((item) => item['nama_permintaan'] == 'Tambah Stok Ayam')
        .map((item) => {
              'jumlah': item['jumlah'],
              'gudang': item['tempat_pendistribusian'],
            })
        .toList();

    return true;
  }

  void _applySummaryFilter() {
    bool matchesFilter(dynamic gudang) =>
        selectedGudang.value == semuaGudang || gudang == selectedGudang.value;

    final totalMasuk = _rawTambahStokMasuk
        .where((item) => matchesFilter(item['gudang']))
        .fold<int>(0, (sum, item) {
          final v = item['jumlah'];
          return sum + (v is int ? v : int.tryParse(v.toString()) ?? 0);
        });

    final totalKeluar = _rawPesananKeluar
        .where((item) => matchesFilter(item['gudang']))
        .fold<int>(0, (sum, item) {
          final v = item['kuantitas'];
          return sum + (v is int ? v : int.tryParse(v.toString()) ?? 0);
        });

    stokKeluar.value = totalKeluar;
    stokAyamGudang.value = (totalMasuk - totalKeluar) < 0 ? 0 : (totalMasuk - totalKeluar);
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

  // Fallback offline — nggak ada cache lokal buat pesanan (pesanan dibuat
  // dari sisi admin/web, bukan dari app ini), jadi kalau lagi offline
  // "keluar" masih pakai perkiraan dari jumlah_daging_jual laporan gudang.
  Future<void> _fetchStokAyamFromLocal() async {
    final tambahList = await _db.getAllTambahStok();
    final laporanList = await _db.getAllLaporanGudang();

    bool matchesFilter(dynamic gudang) =>
        selectedGudang.value == semuaGudang || gudang == selectedGudang.value;

    final totalMasuk = tambahList
        .where((item) => matchesFilter(item['tempat_pendistribusian']))
        .fold<int>(0, (sum, item) => sum + ((item['stok_masuk'] as int?) ?? 0));

    final totalKeluar = laporanList
        .where((item) => matchesFilter(item['tempat_pendistribusian']))
        .fold<int>(
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
            if ((item.gudang ?? '').isNotEmpty) ...[
              Text('Gudang : ${item.gudang}'),
              const SizedBox(height: 8),
            ],
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
        actions: [TextButton(onPressed: Get.back, child: const Text('Tutup'))],
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