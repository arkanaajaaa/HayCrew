import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:haycrew_app/services/gudang_service.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:haycrew_app/utils/error_utils.dart';
import 'package:haycrew_app/utils/image_source_picker.dart';

class TambahStokController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final _db = DBHelper();

  Timer? _pollTimer;

  final stokMasukController = TextEditingController();

  // Dropdown Tempat Pendistribusian — daftar gudangnya diambil dari
  // backend (GudangService) biar ikut nambah kalau admin nambah gudang
  // baru, dipakai bareng dengan LaporanStokController biar konsisten.
  final RxString selectedTempatDistribusi = ''.obs;
  final gudangOptions = <String>[...GudangService.fallback].obs;

  final catatanController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;

  final Rx<File?> image = Rx<File?>(null);

  // Flag untuk mencegah double-tap / error "already_active" pada ImagePicker
  bool _isPickingImage = false;

  final isLoading = false.obs;
  final tambahStokList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTambahStok();
    _loadGudangOptions();
    _pollTimer = Timer.periodic(
      ApiConstant.pollInterval,
      (_) => _loadGudangOptions(),
    );
  }

  Future<void> _loadGudangOptions() async {
    gudangOptions.value = await GudangService.fetchGudangNames(_token);
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial =
        (selectedDate.value != null && !selectedDate.value!.isAfter(today))
        ? selectedDate.value!
        : today;

    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: today,
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      selectedDate.value = picked;
      formattedDate.value = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
    }
  }

  void pickImage() async {
    // Mencegah eksekusi berulang jika galeri/kamera sedang terbuka
    if (_isPickingImage) return;

    try {
      _isPickingImage = true;
      final source = await pickImageSource();
      if (source == null) return;

      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked != null) {
        image.value = File(picked.path);
      }
    } catch (e) {
      debugPrint('ImagePicker Error: $e');
    } finally {
      // Reset flag baik saat sukses, batal, maupun error
      _isPickingImage = false;
    }
  }

  bool _validate() {
    if (stokMasukController.text.isEmpty ||
        selectedTempatDistribusi.value.isEmpty ||
        selectedDate.value == null) {
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
      'stok_masuk': int.parse(stokMasukController.text),
      'tempat_pendistribusian': selectedTempatDistribusi.value,
      'catatan': catatanController.text,
      'foto': image.value?.path,
      'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      'is_synced': 0,
      'created_at': now,
    };

    try {
      final localId = await _db.addTambahStok(localData);

      final success = await _submitToApi(localData);

      if (success) {
        await _db.markTambahStokSynced(localId);
        fetchTambahStok();
        await CSuccessSplash.show(message: 'Stok berhasil\ntersimpan');
        _refreshHomeIfExists();
        Get.back();
      } else {
        fetchTambahStok();
        Get.snackbar(
          'Tersimpan Lokal',
          'Data disimpan lokal, akan disync saat online.',
          backgroundColor: Colors.orange.shade100,
        );
        _refreshHomeIfExists();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshHomeIfExists() {
    if (Get.isRegistered<StorageHomeController>()) {
      Get.find<StorageHomeController>().refreshData();
    }
  }

  Future<bool> _submitToApi(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstant.baseUrl}/api/permintaan');
      debugPrint('Hitting URL: $uri');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      request.fields['nama_permintaan'] = 'Tambah Stok Ayam';
      request.fields['tipe'] = 'barang';
      request.fields['tanggal'] = data['tanggal'];
      request.fields['jumlah'] = data['stok_masuk'].toString();
      request.fields['tempat_pendistribusian'] = data['tempat_pendistribusian'];
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

  Future<void> fetchTambahStok() async {
    final data = await _db.getAllTambahStok();
    tambahStokList.assignAll(data);
  }

  /// Data yang tersimpan lokal tapi belum berhasil dikirim ke server.
  List<Map<String, dynamic>> get pendingTambahStok =>
      tambahStokList.where((l) => l['is_synced'] == 0).toList();

  Future<void> deleteTambahStok(int id) async {
    await _db.deleteTambahStok(id);
    fetchTambahStok();
    Get.snackbar('Berhasil', 'Data dihapus.');
  }

  final isSyncing = <int>{}.obs;

  Future<bool> retrySync(Map<String, dynamic> item) async {
    final id = item['id'] as int;
    isSyncing.add(id);
    try {
      final success = await _submitToApi(item);
      if (success) {
        await _db.markTambahStokSynced(id);
        await fetchTambahStok();
        _refreshHomeIfExists();
        Get.snackbar('Berhasil', 'Data berhasil disinkron.');
      } else {
        Get.snackbar(
          'Gagal',
          'Masih belum bisa terkirim. Coba lagi nanti.',
          backgroundColor: Colors.orange.shade100,
        );
      }
      return success;
    } finally {
      isSyncing.remove(id);
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    stokMasukController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}
