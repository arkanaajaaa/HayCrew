import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import image_picker package sesuai kebutuhan anda
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class LaporanController extends GetxController {
  // Form field controllers
  final jumlahKematianController = TextEditingController();
  final usiaTernakController = TextEditingController();
  final rataBobotController = TextEditingController();
  final catatanController = TextEditingController();

  // Date range
  final dateRange = Rxn<DateTimeRange>();
  final formattedDateRange = 'Pilih Tanggal'.obs;

  // Image
  final Rx<File?> image = Rx<File?>(null);

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
    ); // atau bisa ImageSource.camera
    if (picked != null) {
      image.value = File(picked.path);
    }
  }

  void submit() {
    // Validasi dan submit logic bisa diisi di sini
    // Contoh alert sederhana:
    if (jumlahKematianController.text.isEmpty ||
        usiaTernakController.text.isEmpty ||
        rataBobotController.text.isEmpty ||
        dateRange.value == null) {
      Get.snackbar('Error', 'Mohon lengkapi semua field wajib (*).');
      return;
    }
    // Lakukan simpan data sesuai kebutuhan
    Get.snackbar('Berhasil', 'Laporan berhasil disimpan.');
  }

  @override
  void onClose() {
    jumlahKematianController.dispose();
    usiaTernakController.dispose();
    rataBobotController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}
