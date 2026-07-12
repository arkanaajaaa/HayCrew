import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// LaporanStokController — form "Laporan Gudang" (laporan daging jual keluar).
/// Endpoint: POST /api/laporan-gudang (sesuai route Laravel yang sudah dibuat:
/// index/store/show/update/destroy).
/// Method pengiriman data disamakan PERSIS dengan LaporanController (CKandang):
/// simpan ke SQLite lokal dulu -> coba kirim ke API -> tandai synced kalau
/// berhasil, atau tetap tersimpan lokal (untuk disync nanti) kalau gagal/offline.
class LaporanStokController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final _db = DBHelper();

  final jumlahDagingJualController = TextEditingController();
  final tempatDistribusiController = TextEditingController();
  final catatanController = TextEditingController();

  final dateRange = Rxn<DateTimeRange>();
  final formattedDateRange = 'Pilih Tanggal'.obs;

  final Rx<File?> image = Rx<File?>(null);

  final isLoading = false.obs;
  final laporanGudangList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLaporanGudang();
  }

  void selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      dateRange.value = picked;
      final String formatted =
          "${DateFormat('dd MMM yyyy', 'id_ID').format(picked.start)} — ${DateFormat('dd MMM yyyy', 'id_ID').format(picked.end)}";
      formattedDateRange.value = formatted;
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

  bool _validate() {
    if (jumlahDagingJualController.text.isEmpty ||
        tempatDistribusiController.text.isEmpty ||
        dateRange.value == null) {
      Get.snackbar(
        'Error',
        'Mohon lengkapi semua field wajib (*).',
        backgroundColor: Colors.red.shade100,
      );
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (isLoading.value) return; // cegah double-submit
    if (!_validate()) return;

    isLoading.value = true;

    final now = DateTime.now().toIso8601String();
    final localData = {
      'jumlah_daging_jual': int.parse(jumlahDagingJualController.text),
      'tempat_pendistribusian': tempatDistribusiController.text,
      'catatan': catatanController.text,
      'foto': image.value?.path,
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(dateRange.value!.start),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(dateRange.value!.end),
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
        Get.back();
      } else {
        fetchLaporanGudang();
        Get.snackbar(
          'Tersimpan Lokal',
          'Laporan disimpan lokal, akan disync saat online.',
          backgroundColor: Colors.orange.shade100,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
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

      request.fields['jumlah_daging_jual'] =
          data['jumlah_daging_jual'].toString();
      request.fields['tempat_pendistribusian'] =
          data['tempat_pendistribusian'];
      request.fields['tanggal_mulai'] = data['tanggal_mulai'];
      request.fields['tanggal_selesai'] = data['tanggal_selesai'];
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

  void _resetForm() {
    jumlahDagingJualController.clear();
    tempatDistribusiController.clear();
    catatanController.clear();
    image.value = null;
    dateRange.value = null;
    formattedDateRange.value = 'Pilih Tanggal';
  }

  @override
  void onClose() {
    jumlahDagingJualController.dispose();
    tempatDistribusiController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}