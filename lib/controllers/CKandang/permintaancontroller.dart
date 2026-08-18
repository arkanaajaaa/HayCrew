import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/controllers/home_controller.dart';
import 'package:haycrew_app/utils/error_utils.dart';
import 'package:haycrew_app/utils/currency_input_formatter.dart';

enum JenisPermintaan { barang, dana }

class PermintaanController extends GetxController {
  static const String baseUrl = ApiConstant.baseUrl;

  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final keperluanController = TextEditingController();
  final nominalController = TextEditingController();
  final keteranganController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;
  final jenisPermintaan = JenisPermintaan.dana.obs;
  final isLoading = false.obs;

  String get nominalLabel =>
      jenisPermintaan.value == JenisPermintaan.dana ? 'Nominal*' : 'Jumlah*';

  // Field ini cuma nampung ANGKA jumlah barangnya — nama barangnya sendiri
  // udah ditulis di field "Keperluan" di atas (mis. Keperluan: "Sekam",
  // Jumlah: "10"). Backend juga cuma nerima field `jumlah` sebagai integer
  // murni (lihat PermintaanController::store, validasi `jumlah` =>
  // 'nullable|integer'), jadi hint & keyboard-nya harus konsisten angka.
  String get nominalHint =>
      jenisPermintaan.value == JenisPermintaan.dana ? 'Rp' : 'Contoh: 10';

  TextInputType get nominalKeyboardType =>
      const TextInputType.numberWithOptions(decimal: false);

  List<TextInputFormatter>? get nominalInputFormatters =>
      jenisPermintaan.value == JenisPermintaan.dana
      ? [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()]
      : [FilteringTextInputFormatter.digitsOnly];

  String get submitButtonText => isLoading.value ? 'Mengirim...' : 'Kirim';
  Color get submitButtonColor => isLoading.value
      ? AppColors.primaryGreen.withOpacity(0.6)
      : AppColors.primaryGreen;

  bool get isBarangSelected => jenisPermintaan.value == JenisPermintaan.barang;
  bool get isDanaSelected => jenisPermintaan.value == JenisPermintaan.dana;

  void onTapDatePicker() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      selectedDate.value = picked;
      formattedDate.value = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
    }
  }

  void onSelectJenis(JenisPermintaan jenis) {
    jenisPermintaan.value = jenis;
    nominalController.clear();
  }

  Future<void> submit() async {
    if (!_validate()) return;

    isLoading.value = true;

    try {
      final tipe = jenisPermintaan.value == JenisPermintaan.dana
          ? 'dana'
          : 'barang';

      final Map<String, String> body = {
        'nama_permintaan': keperluanController.text.trim(),
        'tipe': tipe,
        'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      };

      if (tipe == 'dana') {
        body['harga'] = nominalController.text.trim().replaceAll('.', '');
      } else {
        body['jumlah'] = nominalController.text.trim();
      }

      if (keteranganController.text.trim().isNotEmpty) {
        body['keterangan'] = keteranganController.text.trim();
      }

      debugPrint('Body: $body');
      debugPrint('Token: $_token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/permintaan'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _resetForm();

        await CSuccessSplash.show(message: 'Permintaan berhasil\nterkirim');

        // Balik ke dashboard yang udah ada di stack (bukan bikin ulang lewat
        // offAllNamed) — biar HomeController nggak ke-recreate tanpa
        // arguments, yang sebelumnya bikin nama user di "Halo, X" balik ke
        // default begitu abis submit.
        _refreshHomeIfExists();
        Get.back();

        return;
      } else {
        _showError(responseBody['message'] ?? 'Gagal mengirim permintaan.');
      }
    } catch (e, stack) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');
      _showError(friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (selectedDate.value == null) {
      return _showError('Mohon pilih tanggal terlebih dahulu.');
    }
    if (keperluanController.text.trim().isEmpty) {
      return _showError('Keperluan tidak boleh kosong.');
    }
    if (nominalController.text.trim().isEmpty) {
      return _showError(
        '${nominalLabel.replaceAll('*', '')} tidak boleh kosong.',
      );
    }
    final nominal = int.tryParse(nominalController.text.trim().replaceAll('.', ''));
    if (nominal == null || nominal <= 0) {
      final label = jenisPermintaan.value == JenisPermintaan.dana ? 'Nominal' : 'Jumlah';
      return _showError('$label harus lebih dari 0.');
    }
    return true;
  }

  void _refreshHomeIfExists() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadStatusPermintaan(showLoading: false);
    }
  }

  bool _showError(String message) {
    Get.snackbar(
      'Validasi Gagal',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
    );
    return false;
  }

  void _resetForm() {
    keperluanController.clear();
    nominalController.clear();
    keteranganController.clear();
    selectedDate.value = null;
    formattedDate.value = 'Pilih Tanggal';
    jenisPermintaan.value = JenisPermintaan.dana;
  }

  @override
  void onClose() {
    keperluanController.dispose();
    nominalController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}