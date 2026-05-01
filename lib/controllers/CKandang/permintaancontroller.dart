import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:haycrew_app/constants/app_colors.dart';

enum JenisPermintaan { barang, dana }

class PermintaanController extends GetxController {
  // ─── TextEditingControllers ──────────────────────────────────────────────────
  final keperluanController = TextEditingController();
  final nominalController = TextEditingController();
  final keteranganController = TextEditingController();

  // ─── Observable State ────────────────────────────────────────────────────────
  final dateRange = Rxn<DateTimeRange>();
  final formattedDateRange = 'Pilih Tanggal'.obs;
  final jenisPermintaan = JenisPermintaan.dana.obs;
  final isLoading = false.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED GETTERS — UI tinggal bind, tidak perlu tahu kondisi apapun
  // ═══════════════════════════════════════════════════════════════════════════

  String get nominalLabel => jenisPermintaan.value == JenisPermintaan.dana
      ? 'Nominal*'
      : 'Nama Barang*';

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

  VoidCallback get submitButtonCallback => isLoading.value ? () {} : submit;

  /// Warna tombol submit — redup saat loading
  Color get submitButtonColor => isLoading.value
      ? AppColors.primaryGreen.withOpacity(0.6)
      : AppColors.primaryGreen;

  bool get isBarangSelected => jenisPermintaan.value == JenisPermintaan.barang;
  bool get isDanaSelected => jenisPermintaan.value == JenisPermintaan.dana;

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

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

    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 2));

      // TODO: Ganti dengan actual API call
      // await http.post(
      //   Uri.parse('YOUR_API_URL/permintaan'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'jenis'          : jenisPermintaan.value.name,
      //     'keperluan'      : keperluanController.text.trim(),
      //     'nominal'        : nominalController.text.trim(),
      //     'keterangan'     : keteranganController.text.trim(),
      //     'tanggal_mulai'  : dateRange.value!.start.toIso8601String(),
      //     'tanggal_selesai': dateRange.value!.end.toIso8601String(),
      //   }),
      // );

      isLoading.value = false;

      Get.snackbar(
        'Berhasil',
        'Permintaan berhasil dikirim.',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );

      _resetForm();
      Get.back();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal mengirim permintaan: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool _validate() {
    if (dateRange.value == null)
      return _showError('Mohon pilih tanggal terlebih dahulu.');
    if (keperluanController.text.trim().isEmpty)
      return _showError('Keperluan tidak boleh kosong.');
    if (nominalController.text.trim().isEmpty)
      return _showError(
        '${nominalLabel.replaceAll('*', '')} tidak boleh kosong.',
      );
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

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void onClose() {
    keperluanController.dispose();
    nominalController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}
