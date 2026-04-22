import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CKandang/laporancontroller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart'; // Import CButton
import '../../../constants/app_colors.dart';

class LaporanPage extends GetView<LaporanController> {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Laporan Kandang',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Picker
              GestureDetector(
                onTap: controller.selectDateRange,
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: AppColors.textFieldBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.formattedDateRange.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Text('Jumlah kematian*', style: theme.textTheme.bodyMedium),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.jumlahKematianController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ekor'),
                ],
              ),
              const SizedBox(height: 10),

              Text('Usia Ternak*', style: theme.textTheme.bodyMedium),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.usiaTernakController,
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
                'Rata-rata bobot minggu ini*',
                style: theme.textTheme.bodyMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.rataBobotController,
                      hintText: '',
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
              ),
              const SizedBox(height: 18),

              // Upload Gambar
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
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.cloud_upload,
                                color: AppColors.primaryGreen,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Unggah Gambar',
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

              // Tombol Simpan & Kirim menggunakan CButton yang sudah diupdate
              CButton(
                text: 'Simpan & Kirim',
                fontWeight: FontWeight.bold, // Menggunakan properti baru
                fontSize: 16,
                borderRadius: 8, // Menyesuaikan dengan radius input field di atas
                color: AppColors.primaryGreen,
                onPressed: controller.submit,
              ),
              const SizedBox(height: 20), // Tambahan space bawah agar tidak terlalu mepet
            ],
          ),
        ),
      ),
    );
  }
}