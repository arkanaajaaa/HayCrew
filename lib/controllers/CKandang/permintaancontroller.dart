import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/components/CSuccessSplash.dart';
import 'package:haycrew_app/controllers/home_controller.dart';
import 'package:haycrew_app/utils/error_utils.dart';
import 'package:haycrew_app/utils/currency_input_formatter.dart';
import 'package:haycrew_app/utils/image_source_picker.dart';

enum JenisPermintaan { barang, dana }

class PermintaanController extends GetxController {
  static const String baseUrl = ApiConstant.baseUrl;

  final _storage = GetStorage();

  String get _token => _storage.read('token') ?? '';

  final keperluanController = TextEditingController();
  final nominalController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final formattedDate = 'Pilih Tanggal'.obs;
  final jenisPermintaan = JenisPermintaan.dana.obs;
  final isLoading = false.obs;

  final Rx<File?> image = Rx<File?>(null);

  bool _isPickingImage = false;

  String get nominalLabel {
    return jenisPermintaan.value == JenisPermintaan.dana
        ? 'Nominal*'
        : 'Jumlah*';
  }

  String get nominalHint {
    return jenisPermintaan.value == JenisPermintaan.dana
        ? 'Rp'
        : 'Contoh: 10';
  }

  TextInputType get nominalKeyboardType {
    return const TextInputType.numberWithOptions(
      decimal: false,
    );
  }

  List<TextInputFormatter>? get nominalInputFormatters {
    if (jenisPermintaan.value == JenisPermintaan.dana) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        RupiahInputFormatter(),
      ];
    }

    return [
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  String get submitButtonText {
    return isLoading.value ? 'Mengirim...' : 'Kirim';
  }

  Color get submitButtonColor {
    return isLoading.value
        ? AppColors.primaryGreen.withOpacity(0.6)
        : AppColors.primaryGreen;
  }

  bool get isBarangSelected {
    return jenisPermintaan.value == JenisPermintaan.barang;
  }

  bool get isDanaSelected {
    return jenisPermintaan.value == JenisPermintaan.dana;
  }

  void onSelectJenis(JenisPermintaan jenis) {
    jenisPermintaan.value = jenis;
    nominalController.clear();
  }

  void onTapDatePicker() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final initial =
        selectedDate.value != null &&
                !selectedDate.value!.isAfter(today)
            ? selectedDate.value!
            : today;

    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: today,
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;

      formattedDate.value = DateFormat(
        'dd MMM yyyy',
        'id_ID',
      ).format(picked);
    }
  }

  void pickImage() async {
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
      _isPickingImage = false;
    }
  }

  Future<void> submit() async {
    if (!_validate()) return;

    isLoading.value = true;

    try {
      final tipe = jenisPermintaan.value == JenisPermintaan.dana
          ? 'dana'
          : 'barang';

      final uri = Uri.parse(
        '$baseUrl/api/permintaan',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      request.fields['nama_permintaan'] =
          keperluanController.text.trim();

      request.fields['tipe'] = tipe;

      request.fields['tanggal'] =
          DateFormat('yyyy-MM-dd').format(
        selectedDate.value!,
      );

      if (tipe == 'dana') {
        final harga = nominalController.text
            .trim()
            .replaceAll('.', '');

        request.fields['harga'] = harga;

        debugPrint('Harga tampil: ${nominalController.text}');
        debugPrint('Harga dikirim: $harga');
      } else {
        request.fields['jumlah'] =
            nominalController.text.trim();

        debugPrint(
          'Jumlah barang: ${nominalController.text.trim()}',
        );
      }

      if (image.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            image.value!.path,
            filename: path.basename(
              image.value!.path,
            ),
          ),
        );
      }

      debugPrint('Fields: ${request.fields}');
      debugPrint('Token: $_token');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );

      final statusCode = streamedResponse.statusCode;

      final bodyStr =
          await streamedResponse.stream.bytesToString();

      debugPrint('Status: $statusCode');
      debugPrint('Response: $bodyStr');

      if (statusCode == 200 || statusCode == 201) {
        _resetForm();

        await CSuccessSplash.show(
          message: 'Permintaan berhasil\nterkirim',
        );

        _refreshHomeIfExists();

        Get.back();

        return;
      } else {
        dynamic responseBody;

        try {
          responseBody =
              bodyStr.isNotEmpty ? jsonDecode(bodyStr) : null;
        } catch (_) {
          responseBody = null;
        }

        _showError(
          responseBody?['message'] ??
              'Gagal mengirim permintaan.',
        );
      }
    } catch (e, stack) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');

      _showError(
        friendlyErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (selectedDate.value == null) {
      return _showError(
        'Mohon pilih tanggal terlebih dahulu.',
      );
    }

    if (keperluanController.text.trim().isEmpty) {
      return _showError(
        'Keperluan tidak boleh kosong.',
      );
    }

    if (nominalController.text.trim().isEmpty) {
      return _showError(
        '${nominalLabel.replaceAll('*', '')} tidak boleh kosong.',
      );
    }

    final rawValue = nominalController.text
        .trim()
        .replaceAll('.', '');

    final nominal = int.tryParse(rawValue);

    if (nominal == null || nominal <= 0) {
      final label =
          jenisPermintaan.value == JenisPermintaan.dana
              ? 'Nominal'
              : 'Jumlah';

      return _showError(
        '$label harus lebih dari 0.',
      );
    }

    return true;
  }

  void _refreshHomeIfExists() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>()
          .loadStatusPermintaan(
        showLoading: false,
      );
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
    selectedDate.value = null;
    formattedDate.value = 'Pilih Tanggal';
    jenisPermintaan.value = JenisPermintaan.dana;
    image.value = null;
  }

  @override
  void onClose() {
    keperluanController.dispose();
    nominalController.dispose();
    super.onClose();
  }
}