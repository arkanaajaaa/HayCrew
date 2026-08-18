import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CKandang/laporancontroller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CAppBar.dart';
import 'package:haycrew_app/components/CPendingSyncSection.dart';
import '../../../constants/app_colors.dart';

class LaporanPage extends GetView<LaporanController> {
  LaporanPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleTandaiPanen(BuildContext context) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Tandai Panen?'),
        content: const Text(
          'Siklus kandang ini akan ditandai selesai/panen dan tidak bisa lapor lagi setelahnya. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Ya, Panen')),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await controller.tandaiPanen();
    if (success) {
      Get.snackbar('Berhasil', 'Siklus ditandai sebagai panen.',
          backgroundColor: AppColors.primaryGreen.withOpacity(0.15));
      Future.delayed(const Duration(milliseconds: 300), Get.back);
    } else {
      Get.snackbar('Gagal', 'Tidak bisa menandai panen. Coba lagi.',
          backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> _handlePanenDini(BuildContext context) async {
    final catatanController = TextEditingController();
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Panen Lebih Awal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Siklus belum mencapai umur minimum panen. Jelaskan alasan panen dini:'),
            const SizedBox(height: 12),
            TextField(
              controller: catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: ayam terserang penyakit, harga pasar bagus, dll.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Kirim')),
        ],
      ),
    );

    if (confirm != true) return;
    if (catatanController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Alasan panen dini wajib diisi.',
          backgroundColor: Colors.red.shade100);
      return;
    }

    final success = await controller.tandaiPanen(
      catatanPanenDini: catatanController.text.trim(),
    );
    if (success) {
      Get.snackbar('Berhasil', 'Panen dini berhasil dicatat.',
          backgroundColor: AppColors.primaryGreen.withOpacity(0.15));
      Future.delayed(const Duration(milliseconds: 300), Get.back);
    } else {
      Get.snackbar('Gagal', 'Tidak bisa menandai panen dini. Coba lagi.',
          backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CAppBar(title: 'Laporan Kandang'),
      body: Obx(() {
        if (controller.isCheckingSiklus.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.checkSiklusError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat status siklus. Cek koneksi internet kamu.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  CButton(
                    text: 'Coba Lagi',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    borderRadius: 8,
                    color: AppColors.primaryGreen,
                    onPressed: controller.checkSiklusAktif,
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.siklusAktifId.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: AppColors.primaryGreen),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada siklus kandang yang aktif.\nMulai siklus baru sebelum membuat laporan.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  CButton(
                    text: 'Mulai Siklus Baru',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    borderRadius: 8,
                    color: AppColors.primaryGreen,
                    onPressed: () async {
                      final now = DateTime.now();
                      final success = await controller.mulaiSiklusBaru(now);
                      if (success) {
                        Get.snackbar('Berhasil', 'Siklus baru dimulai.');
                      } else {
                        Get.snackbar('Gagal', 'Tidak bisa memulai siklus baru.',
                            backgroundColor: Colors.red.shade100);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CPendingSyncSection(
                  items: controller.pendingLaporan.map((item) {
                    return CPendingSyncItem(
                      id: item['id'] as int,
                      title: 'Laporan ${item['tanggal'] ?? ''}',
                      subtitle:
                          'Ayam mati: ${item['jumlah_ayam_mati'] ?? '-'} • Bobot: ${item['rata_rata_bobot'] ?? '-'} kg',
                    );
                  }).toList(),
                  isSyncing: (id) => controller.isSyncing.contains(id),
                  onRetry: (id) => controller.retrySync(
                    controller.pendingLaporan.firstWhere((l) => l['id'] == id),
                  ),
                  onDelete: (id) => controller.deleteLaporan(id),
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Umur siklus: ${controller.umurHariSiklus.value} hari'
                          '${controller.sudahBolehPanen.value ? ' (sudah boleh panen)' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                if (controller.sudahLaporMingguIni.value) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Laporan minggu ke-${controller.mingguKe.value} sudah diisi. Laporan berikutnya bisa diisi minggu depan.',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (controller.sudahBolehPanen.value) ...[
                  const SizedBox(height: 12),
                  CButton(
                    text: 'Tandai Panen',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    borderRadius: 8,
                    color: Colors.orange,
                    onPressed: () => _handleTandaiPanen(context),
                  ),
                ],

                if (!controller.sudahBolehPanen.value) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _handlePanenDini(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Panen Lebih Awal',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 15),

                if (!controller.sudahLaporMingguIni.value) ...[
                  Text('Tanggal Laporan*', style: theme.textTheme.bodyMedium),
                  GestureDetector(
                    onTap: controller.selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(controller.formattedDate.value),
                          const Icon(Icons.calendar_month, size: 18, color: AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (controller.isLaporanPertama.value) ...[
                    Text('Jumlah Ayam Awal*', style: theme.textTheme.bodyMedium),
                    Row(
                      children: [
                        Expanded(
                          child: CTextField(
                            controller: controller.jumlahAyamAwalController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                              final n = int.tryParse(v.trim());
                              if (n == null) return 'Harus berupa angka';
                              if (n <= 0) return 'Harus lebih dari 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('ekor'),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    controller.isLaporanPertama.value
                        ? 'Jumlah Ayam Mati'
                        : 'Jumlah Ayam Mati*',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (controller.isLaporanPertama.value)
                    const Text(
                      'Opsional untuk laporan pertama siklus ini',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryGreen),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: CTextField(
                          controller: controller.jumlahAyamMatiController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return controller.isLaporanPertama.value ? null : 'Wajib diisi';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null) return 'Harus berupa angka';
                            if (n < 0) return 'Tidak boleh negatif';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('ekor'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Rata-rata Bobot Minggu Ini*',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CTextField(
                          controller: controller.rataBobotController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                            final n = double.tryParse(v.trim());
                            if (n == null) return 'Harus berupa angka';
                            if (n <= 0) return 'Harus lebih dari 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Gram'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text('Catatan', style: theme.textTheme.bodyMedium),
                  CTextField(
                    controller: controller.catatanController,
                    hintText: 'Tulis catatan di sini...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(
                        () => controller.image.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  controller.image.value!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    color: AppColors.primaryGreen,
                                    size: 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Unggah Foto',
                                    style: TextStyle(color: AppColors.primaryGreen),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Klik untuk mengambil foto atau dari galeri',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  CButton(
                    text: controller.isLoading.value
                        ? 'Menyimpan...'
                        : 'Simpan & Kirim',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    borderRadius: 8,
                    color: AppColors.primaryGreen,
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.submit();
                            }
                          },
                  ),
                  const SizedBox(height: 20),
                ],
              ],
              ),
            ),
          ),
        );
      }),
    );
  }
}