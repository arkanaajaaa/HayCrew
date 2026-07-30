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

class TambahStokController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final _db = DBHelper();

  final stokMasukController = TextEditingController();

  // Dropdown Tempat Pendistribusian
  final RxString selectedTempatDistribusi = ''.obs;
  final List<String> listTempatDistribusi = [
    'Gudang Depok',
    'Gudang Bogor',
  ];

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
    // Mencegah eksekusi berulang jika galeri/kamera sedang terbuka
    if (_isPickingImage) return;

    try {
      _isPickingImage = true;
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
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
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
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

      final keterangan = [
        'Tempat distribusi: ${data['tempat_pendistribusian']}',
        if ((data['catatan'] as String?)?.isNotEmpty ?? false) data['catatan'],
      ].join('. ');

      request.fields['nama_permintaan'] = 'Tambah Stok Ayam';
      request.fields['tipe'] = 'barang';
      request.fields['tanggal'] = data['tanggal'];
      request.fields['jumlah'] = data['stok_masuk'].toString();
      request.fields['keterangan'] = keterangan;

      request.fields['tempat_pendistribusian'] =
          data['tempat_pendistribusian'];

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

  Future<void> deleteTambahStok(int id) async {
    await _db.deleteTambahStok(id);
    fetchTambahStok();
    Get.snackbar('Berhasil', 'Data dihapus.');
  }

  @override
  void onClose() {
    stokMasukController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}