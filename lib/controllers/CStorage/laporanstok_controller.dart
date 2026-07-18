import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Satu baris entri stok daging: Jenis (Whole/Parting/dst), Bobot per unit
/// (kg), dan Jumlah unit. Contoh tampilan: "3   Whole   0,7 kg".
class StokDagingItem {
  final String id;
  final String jenis;
  final double bobot; // kg per unit
  final int jumlah; // banyaknya unit

  StokDagingItem({
    required this.id,
    required this.jenis,
    required this.bobot,
    required this.jumlah,
  });

  /// total kg dari baris ini (bobot per unit x jumlah unit)
  double get totalBobot => bobot * jumlah;

  Map<String, dynamic> toJson() => {
        'jenis': jenis,
        'bobot': bobot,
        'jumlah': jumlah,
      };
}

class LaporanStokController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final _db = DBHelper();

  // Form "Tambah Stok Daging" (dipakai di bottom sheet)
  final jenisController = TextEditingController();
  final bobotController = TextEditingController();
  final jumlahController = TextEditingController();

  final tempatDistribusiController = TextEditingController();
  final catatanController = TextEditingController();

  // Wajib diisi backend: stok_awal & stok_masuk (integer).
  // TODO: konfirmasi ke tim backend apakah satuannya ekor atau kg, lalu
  // sesuaikan hint text di laporanstokpage.dart kalau perlu.
  final stokAwalController = TextEditingController();
  final stokMasukController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;

  final Rx<File?> image = Rx<File?>(null);

  final isLoading = false.obs;
  final laporanGudangList = <Map<String, dynamic>>[].obs;

  // List breakdown stok daging (Jenis / Bobot / Jumlah) yang ditambahkan user
  final stokDagingList = <StokDagingItem>[].obs;

  /// Total kg daging (jumlah bobot x jumlah unit di semua baris).
  /// Dikirim ke API sebagai `jumlah_daging_jual` — backend mewajibkan ini
  /// berupa integer, jadi saat submit dibulatkan (lihat `_submitToApi`).
  double get totalDagingJual =>
      stokDagingList.fold(0.0, (sum, item) => sum + item.totalBobot);

  @override
  void onInit() {
    super.onInit();
    fetchLaporanGudang();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      selectedDate.value = picked;
      formattedDate.value = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
    }
  }

  void pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      image.value = File(picked.path);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STOK DAGING (list Jenis/Bobot/Jumlah)
  // ═══════════════════════════════════════════════════════════════════════

  bool _validateStokDagingForm() {
    if (jenisController.text.trim().isEmpty ||
        bobotController.text.trim().isEmpty ||
        jumlahController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Lengkapi Jenis, Bobot, dan Jumlah dulu.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    final bobot = double.tryParse(bobotController.text.replaceAll(',', '.'));
    final jumlah = int.tryParse(jumlahController.text);
    if (bobot == null || bobot <= 0) {
      Get.snackbar(
        'Error',
        'Bobot harus berupa angka lebih dari 0.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    if (jumlah == null || jumlah <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah harus berupa angka lebih dari 0.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    return true;
  }

  void addStokDaging() {
    if (!_validateStokDagingForm()) return;

    final bobot = double.parse(bobotController.text.replaceAll(',', '.'));
    final jumlah = int.parse(jumlahController.text);

    stokDagingList.add(
      StokDagingItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        jenis: jenisController.text.trim(),
        bobot: bobot,
        jumlah: jumlah,
      ),
    );

    jenisController.clear();
    bobotController.clear();
    jumlahController.clear();
    Get.back(); // tutup bottom sheet tambah item
  }

  void removeStokDaging(String id) {
    stokDagingList.removeWhere((item) => item.id == id);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SUBMIT LAPORAN
  // ═══════════════════════════════════════════════════════════════════════

  bool _validate() {
    if (stokDagingList.isEmpty) {
      Get.snackbar(
        'Error',
        'Tambahkan minimal 1 data stok daging.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    if (tempatDistribusiController.text.isEmpty || selectedDate.value == null) {
      Get.snackbar(
        'Error',
        'Mohon lengkapi semua field wajib (*).',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    if (stokAwalController.text.trim().isEmpty ||
        int.tryParse(stokAwalController.text.trim()) == null) {
      Get.snackbar(
        'Error',
        'Stok Awal wajib diisi dengan angka.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    if (stokMasukController.text.trim().isEmpty ||
        int.tryParse(stokMasukController.text.trim()) == null) {
      Get.snackbar(
        'Error',
        'Stok Masuk wajib diisi dengan angka.',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (isLoading.value) return;
    if (!_validate()) return;

    isLoading.value = true;

    final now = DateTime.now().toIso8601String();
    final localData = {
      'stok_awal': int.parse(stokAwalController.text.trim()),
      'stok_masuk': int.parse(stokMasukController.text.trim()),
      'jumlah_daging_jual': totalDagingJual,
      'detail_stok': jsonEncode(
        stokDagingList.map((item) => item.toJson()).toList(),
      ),
      'tempat_pendistribusian': tempatDistribusiController.text,
      'catatan': catatanController.text,
      'foto': image.value?.path,
      'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      'is_synced': 0,
      'created_at': now,
    };

    try {
      final localId = await _db.addLaporanGudang(localData);

      final success = await _submitToApi(localData);

      if (success) {
        await _db.markLaporanGudangSynced(localId);
        fetchLaporanGudang();
        await CSuccessSplash.show(message: 'Laporan berhasil\ntersimpan');
        _refreshHomeIfExists();
        Get.back();
      } else {
        fetchLaporanGudang();
        Get.snackbar(
          'Tersimpan Lokal',
          'Laporan disimpan lokal, akan disync saat online.',
          backgroundColor: Colors.orange.shade100,
        );
        _refreshHomeIfExists();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh ringkasan & daftar stok di homepage storage (StorageHomeController)
  /// supaya kartu-kartu di homepage langsung update begitu user balik dari
  /// form ini, tanpa perlu pull-to-refresh manual.
  void _refreshHomeIfExists() {
    if (Get.isRegistered<StorageHomeController>()) {
      Get.find<StorageHomeController>().refreshData();
    }
  }

  Future<bool> _submitToApi(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstant.baseUrl}/api/laporan-gudang');
      debugPrint('Hitting URL: $uri');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      request.fields['stok_awal'] = data['stok_awal'].toString();
      request.fields['stok_masuk'] = data['stok_masuk'].toString();
      // Backend mewajibkan integer, jadi dibulatkan saat dikirim.
      // Nilai desimal aslinya tetap tersimpan lokal (kolom REAL) untuk presisi.
      request.fields['jumlah_daging_jual'] =
          (data['jumlah_daging_jual'] as double).round().toString();
      request.fields['detail_stok'] = data['detail_stok'];
      request.fields['tempat_pendistribusian'] =
          data['tempat_pendistribusian'];
      request.fields['tanggal'] = data['tanggal'];
      if (data['catatan'] != null && data['catatan'].toString().isNotEmpty) {
        request.fields['catatan'] = data['catatan'];
      }

      if (data['foto'] != null && data['foto'].toString().isNotEmpty) {
        final file = File(data['foto']);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'foto',
              file.path,
              filename: path.basename(file.path),
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final statusCode = streamedResponse.statusCode;
      final body = await streamedResponse.stream.bytesToString();
      debugPrint('Status: $statusCode, Body: $body');

      return statusCode == 200 || statusCode == 201;
    } catch (e) {
      debugPrint('API Error: $e');
      return false;
    }
  }

  Future<void> fetchLaporanGudang() async {
    final data = await _db.getAllLaporanGudang();
    laporanGudangList.assignAll(data);
  }

  Future<void> deleteLaporanGudang(int id) async {
    await _db.deleteLaporanGudang(id);
    fetchLaporanGudang();
    Get.snackbar('Berhasil', 'Laporan dihapus.');
  }

  @override
  void onClose() {
    jenisController.dispose();
    bobotController.dispose();
    jumlahController.dispose();
    tempatDistribusiController.dispose();
    catatanController.dispose();
    stokAwalController.dispose();
    stokMasukController.dispose();
    super.onClose();
  }
}