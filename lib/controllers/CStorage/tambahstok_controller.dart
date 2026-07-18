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

/// TambahStokController — form "Tambah Stok" (stok masuk dari kandang).
///
/// PENTING: Tampilan form-nya tetap (Stok Masuk/ekor, Tempat Pendistribusian,
/// Catatan, Upload Foto), TAPI backend-nya ternyata bukan endpoint sendiri —
/// ini nyambung ke sistem "Permintaan" yang sudah ada di kandang module
/// (POST /api/permintaan), dengan field di-mapping seperti berikut:
///   - nama_permintaan : 'Tambah Stok Ayam' (fixed, biar gampang difilter)
///   - tipe            : 'barang'
///   - tanggal         : tanggal tunggal yang dipilih user
///   - jumlah          : nilai Stok Masuk (ekor)
///   - keterangan      : gabungan Tempat Pendistribusian + Catatan
///   - foto            : file upload (tambahan baru, PermintaanController versi
///                       kandang belum kirim foto — cek dulu ke backend apakah
///                       field 'foto' ini didukung di controller Laravel-nya)
///
/// Method pengiriman data (simpan lokal dulu -> coba kirim ke API -> tandai
/// synced kalau berhasil / tetap tersimpan lokal kalau gagal) tetap sama
/// persis dengan LaporanController (CKandang).
///
/// Catatan migrasi: form ini sebelumnya pakai date RANGE, tapi endpoint
/// /api/permintaan cuma pernah terima 1 tanggal (dulu dipakai tanggal_mulai
/// saja, tanggal_selesai tidak pernah dipakai). Karena itu diubah jadi
/// single date, sekaligus tabel lokal `tambah_stok` dimigrasi ke kolom
/// `tanggal` tunggal (lihat dbService.dart versi 6).
class TambahStokController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final _db = DBHelper();

  final stokMasukController = TextEditingController();
  final tempatDistribusiController = TextEditingController();
  final catatanController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;

  final Rx<File?> image = Rx<File?>(null);

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
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      image.value = File(picked.path);
    }
  }

  bool _validate() {
    if (stokMasukController.text.isEmpty ||
        tempatDistribusiController.text.isEmpty ||
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
    // Data yang disimpan lokal (struktur tabel tambah_stok versi baru,
    // kolom `tanggal` tunggal — lihat dbService.dart)
    final localData = {
      'stok_masuk': int.parse(stokMasukController.text),
      'tempat_pendistribusian': tempatDistribusiController.text,
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

  /// Refresh ringkasan & daftar stok di homepage storage (StorageHomeController)
  /// supaya kartu-kartu di homepage langsung update begitu user balik dari
  /// form ini, tanpa perlu pull-to-refresh manual. Dicek dulu apakah
  /// controllernya masih ke-register di memory (harusnya masih, karena
  /// halaman ini cuma di-push di atas homepage, bukan menggantikannya).
  void _refreshHomeIfExists() {
    if (Get.isRegistered<StorageHomeController>()) {
      Get.find<StorageHomeController>().refreshData();
    }
  }

  /// Kirim ke endpoint /api/permintaan (bukan /api/tambah-stok — lihat
  /// penjelasan mapping field di dokumentasi class di atas).
  Future<bool> _submitToApi(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstant.baseUrl}/api/permintaan');
      debugPrint('Hitting URL: $uri');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      // Gabungkan Tempat Pendistribusian + Catatan ke satu field 'keterangan'
      // karena endpoint /api/permintaan tidak punya kolom khusus untuk itu.
      final keterangan = [
        'Tempat distribusi: ${data['tempat_pendistribusian']}',
        if ((data['catatan'] as String?)?.isNotEmpty ?? false) data['catatan'],
      ].join('. ');

      request.fields['nama_permintaan'] = 'Tambah Stok Ayam';
      request.fields['tipe'] = 'barang';
      request.fields['tanggal'] = data['tanggal'];
      request.fields['jumlah'] = data['stok_masuk'].toString();
      request.fields['keterangan'] = keterangan;

      // Field tambahan (jaga-jaga kalau backend punya kolom ini juga,
      // aman untuk dikirim meski nanti diabaikan backend).
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
    tempatDistribusiController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}























// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:haycrew_app/services/dbService.dart';
// import 'package:haycrew_app/components/CSuccessSplash.dart';
// import 'package:haycrew_app/constants/api_constant.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;

// /// TambahStokController — form "Tambah Stok" (stok masuk dari kandang).
// ///
// /// PENTING: Tampilan form-nya tetap (Stok Masuk/ekor, Tempat Pendistribusian,
// /// Catatan, Upload Foto), TAPI backend-nya ternyata bukan endpoint sendiri —
// /// ini nyambung ke sistem "Permintaan" yang sudah ada di kandang module
// /// (POST /api/permintaan), dengan field di-mapping seperti berikut:
// ///   - nama_permintaan : 'Tambah Stok Ayam' (fixed, biar gampang difilter)
// ///   - tipe            : 'barang'
// ///   - tanggal         : tanggal tunggal yang dipilih user
// ///   - jumlah          : nilai Stok Masuk (ekor)
// ///   - keterangan      : gabungan Tempat Pendistribusian + Catatan
// ///   - foto            : file upload (tambahan baru, PermintaanController versi
// ///                       kandang belum kirim foto — cek dulu ke backend apakah
// ///                       field 'foto' ini didukung di controller Laravel-nya)
// ///
// /// Method pengiriman data (simpan lokal dulu -> coba kirim ke API -> tandai
// /// synced kalau berhasil / tetap tersimpan lokal kalau gagal) tetap sama
// /// persis dengan LaporanController (CKandang).
// ///
// /// Catatan migrasi: form ini sebelumnya pakai date RANGE, tapi endpoint
// /// /api/permintaan cuma pernah terima 1 tanggal (dulu dipakai tanggal_mulai
// /// saja, tanggal_selesai tidak pernah dipakai). Karena itu diubah jadi
// /// single date, sekaligus tabel lokal `tambah_stok` dimigrasi ke kolom
// /// `tanggal` tunggal (lihat dbService.dart versi 6).
// class TambahStokController extends GetxController {
//   final _storage = GetStorage();
//   String get _token => _storage.read('token') ?? '';

//   final _db = DBHelper();

//   final stokMasukController = TextEditingController();
//   final tempatDistribusiController = TextEditingController();
//   final catatanController = TextEditingController();

//   final selectedDate = Rxn<DateTime>();
//   final formattedDate = 'Pilih Tanggal'.obs;

//   final Rx<File?> image = Rx<File?>(null);

//   final isLoading = false.obs;
//   final tambahStokList = <Map<String, dynamic>>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchTambahStok();
//   }

//   Future<void> selectDate() async {
//     final picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: selectedDate.value ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       locale: const Locale('id', 'ID'),
//     );
//     if (picked != null) {
//       selectedDate.value = picked;
//       formattedDate.value = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
//     }
//   }

//   void pickImage() async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (picked != null) {
//       image.value = File(picked.path);
//     }
//   }

//   bool _validate() {
//     if (stokMasukController.text.isEmpty ||
//         tempatDistribusiController.text.isEmpty ||
//         selectedDate.value == null) {
//       Get.snackbar(
//         'Error',
//         'Mohon lengkapi semua field wajib (*).',
//         backgroundColor: Colors.red.shade100,
//       );
//       return false;
//     }
//     return true;
//   }

//   Future<void> submit() async {
//     if (isLoading.value) return; // cegah double-submit
//     if (!_validate()) return;

//     isLoading.value = true;

//     final now = DateTime.now().toIso8601String();
//     // Data yang disimpan lokal (struktur tabel tambah_stok versi baru,
//     // kolom `tanggal` tunggal — lihat dbService.dart)
//     final localData = {
//       'stok_masuk': int.parse(stokMasukController.text),
//       'tempat_pendistribusian': tempatDistribusiController.text,
//       'catatan': catatanController.text,
//       'foto': image.value?.path,
//       'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
//       'is_synced': 0,
//       'created_at': now,
//     };

//     try {
//       final localId = await _db.addTambahStok(localData);

//       final success = await _submitToApi(localData);

//       if (success) {
//         await _db.markTambahStokSynced(localId);
//         fetchTambahStok();
//         await CSuccessSplash.show(message: 'Stok berhasil\ntersimpan');
//         Get.back();
//       } else {
//         fetchTambahStok();
//         Get.snackbar(
//           'Tersimpan Lokal',
//           'Data disimpan lokal, akan disync saat online.',
//           backgroundColor: Colors.orange.shade100,
//         );
//         Get.back();
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Terjadi kesalahan: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Kirim ke endpoint /api/permintaan (bukan /api/tambah-stok — lihat
//   /// penjelasan mapping field di dokumentasi class di atas).
//   Future<bool> _submitToApi(Map<String, dynamic> data) async {
//     try {
//       final uri = Uri.parse('${ApiConstant.baseUrl}/api/permintaan');
//       debugPrint('Hitting URL: $uri');
//       final request = http.MultipartRequest('POST', uri);

//       request.headers.addAll({
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//       });

//       // Gabungkan Tempat Pendistribusian + Catatan ke satu field 'keterangan'
//       // karena endpoint /api/permintaan tidak punya kolom khusus untuk itu.
//       final keterangan = [
//         'Tempat distribusi: ${data['tempat_pendistribusian']}',
//         if ((data['catatan'] as String?)?.isNotEmpty ?? false) data['catatan'],
//       ].join('. ');

//       request.fields['nama_permintaan'] = 'Tambah Stok Ayam';
//       request.fields['tipe'] = 'barang';
//       request.fields['tanggal'] = data['tanggal'];
//       request.fields['jumlah'] = data['stok_masuk'].toString();
//       request.fields['keterangan'] = keterangan;

//       // Field tambahan (jaga-jaga kalau backend punya kolom ini juga,
//       // aman untuk dikirim meski nanti diabaikan backend).
//       request.fields['tempat_pendistribusian'] =
//           data['tempat_pendistribusian'];

//       if (data['foto'] != null && data['foto'].toString().isNotEmpty) {
//         final file = File(data['foto']);
//         if (await file.exists()) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'foto',
//               file.path,
//               filename: path.basename(file.path),
//             ),
//           );
//         }
//       }

//       final streamedResponse = await request.send().timeout(
//         const Duration(seconds: 30),
//       );
//       final statusCode = streamedResponse.statusCode;
//       final body = await streamedResponse.stream.bytesToString();
//       debugPrint('Status: $statusCode, Body: $body');

//       return statusCode == 200 || statusCode == 201;
//     } catch (e) {
//       debugPrint('API Error: $e');
//       return false;
//     }
//   }

//   Future<void> fetchTambahStok() async {
//     final data = await _db.getAllTambahStok();
//     tambahStokList.assignAll(data);
//   }

//   Future<void> deleteTambahStok(int id) async {
//     await _db.deleteTambahStok(id);
//     fetchTambahStok();
//     Get.snackbar('Berhasil', 'Data dihapus.');
//   }

//   @override
//   void onClose() {
//     stokMasukController.dispose();
//     tempatDistribusiController.dispose();
//     catatanController.dispose();
//     super.onClose();
//   }
// }