import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:haycrew_app/components/CSuccessSplash.dart';

class LaporanController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';
  static const String baseUrl = 'http://103.253.212.178';

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
  final siklusAktifId = Rxn<int>();
  final isLaporanPertama = true.obs;
  final umurHariSiklus = 0.obs;
  final mingguKe = 1.obs;
  final sudahLaporMingguIni = false.obs;
  final sudahBolehPanen = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
    checkSiklusAktif();
  }

  Future<void> checkSiklusAktif() async {
    isCheckingSiklus.value = true;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/siklus-kandang/aktif'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
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
      }
    } catch (_) {
      // biarin default kalau gagal fetch (offline dll)
    } finally {
      isCheckingSiklus.value = false;
    }
  }

  Future<void> _checkLaporanPertama(int siklusId) async {
    final adaLaporan = laporanList.any((l) => l['siklus_id'] == siklusId);
    isLaporanPertama.value = !adaLaporan;
  }

  void selectDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
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
    if (jumlahAyamMatiController.text.isEmpty ||
        rataBobotController.text.isEmpty ||
        selectedDate.value == null) {
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
      'jumlah_ayam_mati': int.parse(jumlahAyamMatiController.text),
      'rata_rata_bobot': double.parse(rataBobotController.text),
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
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG);
        });
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
        if (['foto', 'is_synced', 'created_at'].contains(k)) return;
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
      print('TandaiPanen gagal: ${res.statusCode} - ${res.body}');
      return false;
    } catch (e) {
      print('TandaiPanen error: $e'); 
      return false;
    }
  }

  Future<void> fetchLaporan() async => laporanList.assignAll(await _db.getAllLaporan());

  Future<void> deleteLaporan(int id) async {
    await _db.deleteLaporan(id);
    await fetchLaporan();
    Get.snackbar('Berhasil', 'Laporan dihapus.');
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