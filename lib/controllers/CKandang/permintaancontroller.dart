import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';

enum JenisPermintaan { barang, dana }

class PermintaanController extends GetxController {
  static const String baseUrl = 'http://103.253.212.178';

  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final keperluanController = TextEditingController();
  final nominalController = TextEditingController();
  final keteranganController = TextEditingController();

  final dateRange = Rxn<DateTimeRange>();
  final formattedDateRange = 'Pilih Tanggal'.obs;
  final jenisPermintaan = JenisPermintaan.dana.obs;
  final isLoading = false.obs;

  String get nominalLabel =>
      jenisPermintaan.value == JenisPermintaan.dana ? 'Nominal*' : 'Jumlah*';

  String get nominalHint => jenisPermintaan.value == JenisPermintaan.dana
      ? 'Rp'
      : 'Contoh: Sekam 10 karung';

  TextInputType get nominalKeyboardType =>
      jenisPermintaan.value == JenisPermintaan.dana
      ? const TextInputType.numberWithOptions(decimal: false)
      : TextInputType.text;

  List<TextInputFormatter>? get nominalInputFormatters =>
      jenisPermintaan.value == JenisPermintaan.dana
      ? [FilteringTextInputFormatter.digitsOnly]
      : null;

  String get submitButtonText => isLoading.value ? 'Mengirim...' : 'Kirim';
  Color get submitButtonColor => isLoading.value
      ? AppColors.primaryGreen.withOpacity(0.6)
      : AppColors.primaryGreen;

  bool get isBarangSelected => jenisPermintaan.value == JenisPermintaan.barang;
  bool get isDanaSelected => jenisPermintaan.value == JenisPermintaan.dana;

  void onTapDatePicker() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
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
      dateRange.value = picked;
      formattedDateRange.value =
          "${DateFormat('dd MMM yyyy', 'id_ID').format(picked.start)} \u2014 "
          "${DateFormat('dd MMM yyyy', 'id_ID').format(picked.end)}";
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
        'tanggal': DateFormat('yyyy-MM-dd').format(dateRange.value!.start),
      };

      if (tipe == 'dana') {
        body['harga'] = nominalController.text.trim();
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

        Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG);

        return;
      } else {
        _showError(responseBody['message'] ?? 'Gagal mengirim permintaan.');
      }
    } catch (e, stack) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');
      _showError('Gagal mengirim permintaan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (dateRange.value == null) {
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
    return true;
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
    dateRange.value = null;
    formattedDateRange.value = 'Pilih Tanggal';
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
