import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CKandang/laporancontroller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CAppBar.dart';
import 'package:haycrew_app/components/CDateRangePicker.dart';
import '../../../constants/app_colors.dart';

class LaporanPage extends GetView<LaporanController> {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CAppBar(title: 'Laporan Kandang'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => CDateRangePicker(
                  displayText: controller.formattedDateRange.value,
                  onTap: controller.selectDateRange,
                ),
              ),
              const SizedBox(height: 15),

              Text('Jumlah Ayam Awal*', style: theme.textTheme.bodyMedium),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.jumlahAyamAwalController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ekor'),
                ],
              ),
              const SizedBox(height: 10),

              Text('Jumlah Ayam Mati*', style: theme.textTheme.bodyMedium),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.jumlahAyamMatiController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ekor'),
                ],
              ),
              const SizedBox(height: 10),

              Text('Umur Ayam*', style: theme.textTheme.bodyMedium),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.umurAyamController,
                      hintText: 'Contoh : 70',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('hari'),
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

              Obx(
                () => CButton(
                  text: controller.isLoading.value
                      ? 'Menyimpan...'
                      : 'Simpan & Kirim',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  borderRadius: 8,
                  color: AppColors.primaryGreen,
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submit(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
