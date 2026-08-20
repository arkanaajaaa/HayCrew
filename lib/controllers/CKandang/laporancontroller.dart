import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/controllers/home_controller.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/utils/image_source_picker.dart';
import 'package:flutter/services.dart';

class LaporanController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';
  static const String baseUrl = ApiConstant.baseUrl;

  final _db = DBHelper();

  final jumlahAyamAwalController = TextEditingController();
  final jumlahAyamMatiController = TextEditingController();
  final rataBobotController = TextEditingController();
  final catatanController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;
  final Rx<File?> image = Rx<File?>(null);
  final isLoading = false.obs;
  final laporanList = <Map<String, dynamic>>[].obs;

  final isCheckingSiklus = true.obs;
  final checkSiklusError = false.obs;
  final siklusAktifId = Rxn<int>();
  final isLaporanPertama = true.obs;
  final umurHariSiklus = 0.obs;
  final mingguKe = 1.obs;
  final sudahLaporMingguIni = false.obs;
  final sudahBolehPanen = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listener: ubah titik (.) menjadi koma (,) saat user mengetik
    // supaya input langsung tampil dengan format lokal (0,5).
    rataBobotController.addListener(() {
      final text = rataBobotController.text;
      if (text.contains('.')) {
        final newText = text.replaceAll('.', ',');
        final baseOffset = rataBobotController.selection.baseOffset;
        final extentOffset = rataBobotController.selection.extentOffset;
        // Pastikan selection tetap valid setelah perubahan (panjang tidak berubah
        // karena '.' diganti dengan ',' sehingga offset tetap aman).
        final newSelection = TextSelection(
          baseOffset: baseOffset,
          extentOffset: extentOffset,
        );
        rataBobotController.value = TextEditingValue(
          text: newText,
          selection: newSelection,
        );
      }
    });

    fetchLaporan();
    checkSiklusAktif();
  }

  Future<void> checkSiklusAktif() async {
    isCheckingSiklus.value = true;
    checkSiklusError.value = false;
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/api/siklus-kandang/aktif'),
            headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded['data'];
        if (data != null) {
          siklusAktifId.value = data['id'];
          umurHariSiklus.value = data['umur_hari'] ?? 0;
          mingguKe.value = data['minggu_ke'] ?? 1;
          sudahLaporMingguIni.value = data['sudah_lapor_minggu_ini'] ?? false;
          sudahBolehPanen.value = data['sudah_boleh_panen'] ?? false;
          await _checkLaporanPertama(data['id']);
        } else {
          siklusAktifId.value = null;
          isLaporanPertama.value = true;
        }
      } else {
        siklusAktifId.value = null;
        checkSiklusError.value = true;
      }
    } catch (_) {
      siklusAktifId.value = null;
      checkSiklusError.value = true;
    } finally {
      isCheckingSiklus.value = false;
    }
  }

  Future<void> _checkLaporanPertama(int siklusId) async {
    final adaLaporan = laporanList.any((l) => l['siklus_id'] == siklusId);
    isLaporanPertama.value = !adaLaporan;
  }

  void selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (selectedDate.value != null && !selectedDate.value!.isAfter(today))
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
    final source = await pickImageSource();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) image.value = File(picked.path);
  }

  bool _validate() {
    if (siklusAktifId.value == null) {
      Get.snackbar('Belum Ada Siklus', 'Mulai siklus kandang baru dulu sebelum lapor.',
          backgroundColor: Colors.orange.shade100);
      return false;
    }
    if (sudahLaporMingguIni.value) {
      Get.snackbar('Sudah Lapor', 'Kamu sudah mengisi laporan untuk minggu ke-${mingguKe.value} siklus ini.',
          backgroundColor: Colors.orange.shade100);
      return false;
    }
    if (isLaporanPertama.value && jumlahAyamAwalController.text.isEmpty) {
      Get.snackbar('Error', 'Jumlah ayam awal wajib diisi untuk laporan pertama siklus ini.',
          backgroundColor: Colors.red.shade100);
      return false;
    }
    // Laporan pertama siklus baru mulai — belum masuk akal nanya jumlah
    // ayam mati, jadi field ini opsional (default 0) khusus di sini.
    if (!isLaporanPertama.value && jumlahAyamMatiController.text.isEmpty) {
      Get.snackbar('Error', 'Mohon lengkapi semua field wajib (*)',
          backgroundColor: Colors.red.shade100);
      return false;
    }
    if (rataBobotController.text.isEmpty || selectedDate.value == null) {
      Get.snackbar('Error', 'Mohon lengkapi semua field wajib (*)',
          backgroundColor: Colors.red.shade100);
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;
    isLoading.value = true;

    final now = DateTime.now().toIso8601String();
    final localData = <String, dynamic>{
      'jumlah_ayam_mati': jumlahAyamMatiController.text.isEmpty
          ? 0
          : int.parse(jumlahAyamMatiController.text),
      // parse angka dengan mengganti koma -> titik agar double.parse bisa membaca
      'rata_rata_bobot': double.parse(rataBobotController.text.replaceAll(',', '.')),
      'catatan': catatanController.text,
      'foto': image.value?.path,
      'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      'is_synced': 0,
      'created_at': now,
      'siklus_id': siklusAktifId.value,
    };

    if (isLaporanPertama.value) {
      localData['jumlah_ayam_awal'] = int.parse(jumlahAyamAwalController.text);
    }

    try {
      final id = await _db.addLaporan(localData);
      final success = await _submitToApi(localData);

      if (success) {
        await _db.markAsSynced(id);
        _resetForm();
        await fetchLaporan();
        await checkSiklusAktif();
        await CSuccessSplash.show(message: 'Laporan berhasil\ntersimpan');
        _refreshHomeIfExists();
        Get.back();
      } else {
        Get.snackbar('Tersimpan Lokal', 'Laporan disimpan lokal, akan disync saat online.',
            backgroundColor: Colors.orange.shade100);
        _resetForm();
        await fetchLaporan();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _submitToApi(Map<String, dynamic> data) async {
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/laporan-kandang'));
      req.headers.addAll({'Accept': 'application/json', 'Authorization': 'Bearer $_token'});
      data.forEach((k, v) {
        if (['id', 'foto', 'is_synced', 'created_at'].contains(k)) return;
        if (v != null) req.fields[k] = v.toString();
      });
      if (data['foto'] != null) {
        final f = File(data['foto']);
        if (await f.exists()) {
          req.files.add(await http.MultipartFile.fromPath('foto', f.path, filename: path.basename(f.path)));
        }
      }
      final res = await req.send().timeout(const Duration(seconds: 30));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> mulaiSiklusBaru(DateTime tanggalMulai) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/siklus-kandang'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'tanggal_mulai': DateFormat('yyyy-MM-dd').format(tanggalMulai)}),
      );
      if (res.statusCode == 201) {
        await checkSiklusAktif();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> tandaiPanen({String? catatanPanenDini}) async {
    if (siklusAktifId.value == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/siklus-kandang/${siklusAktifId.value}/panen'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          catatanPanenDini != null ? {'catatan_panen_dini': catatanPanenDini} : {},
        ),
      );
      if (res.statusCode == 200) {
        await checkSiklusAktif();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchLaporan() async => laporanList.assignAll(await _db.getAllLaporan());

  void _refreshHomeIfExists() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadStatusPermintaan(showLoading: false);
    }
  }

  List<Map<String, dynamic>> get pendingLaporan =>
      laporanList.where((l) => l['is_synced'] == 0).toList();

  Future<void> deleteLaporan(int id) async {
    await _db.deleteLaporan(id);
    await fetchLaporan();
    Get.snackbar('Berhasil', 'Laporan dihapus.');
  }

  final isSyncing = <int>{}.obs;

  Future<bool> retrySync(Map<String, dynamic> item) async {
    final id = item['id'] as int;
    isSyncing.add(id);
    try {
      final success = await _submitToApi(item);
      if (success) {
        await _db.markAsSynced(id);
        await fetchLaporan();
        Get.snackbar('Berhasil', 'Laporan berhasil disinkron.');
      } else {
        Get.snackbar('Gagal', 'Masih belum bisa terkirim. Coba lagi nanti.',
            backgroundColor: Colors.orange.shade100);
      }
      return success;
    } finally {
      isSyncing.remove(id);
    }
  }

  void _resetForm() {
    jumlahAyamAwalController.clear();
    jumlahAyamMatiController.clear();
    rataBobotController.clear();
    catatanController.clear();
    image.value = null;
    selectedDate.value = null;
    formattedDate.value = 'Pilih Tanggal';
  }

  @override
  void onClose() {
    jumlahAyamAwalController.dispose();
    jumlahAyamMatiController.dispose();
    rataBobotController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}