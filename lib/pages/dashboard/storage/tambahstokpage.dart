import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CStorage/tambahstok_controller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/CDaterangepicker.dart';
import 'package:haycrew_app/components/CUploadimagepage.dart';
import '../../../constants/app_colors.dart';

class TambahStokPage extends GetView<TambahStokController> {
  const TambahStokPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CAppBar(title: 'Tambah Stok'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Single date -> controller.formattedDate / controller.selectDate
              // (butuh TambahStokController diupdate + tabel tambah_stok
              // dimigrasi ke kolom `tanggal` tunggal, lihat catatan di chat).
              Obx(
                () => CDateRangePicker(
                  displayText: controller.formattedDate.value,
                  onTap: controller.selectDate,
                ),
              ),
              const SizedBox(height: 18),

              Text('Stok Masuk*', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.stokMasukController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ekor'),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '* Jumlah ayam yang diterima dari kandang',
                style: TextStyle(fontSize: 12, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 18),

              Text('Tempat Pendistribusian*', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              CTextField(
                controller: controller.tempatDistribusiController,
                hintText: 'Contoh : Pasar Induk',
              ),
              const SizedBox(height: 18),

              Text('Catatan', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              CTextField(
                controller: controller.catatanController,
                hintText: 'Tulis catatan di sini...',
                maxLines: 4,
              ),
              const SizedBox(height: 18),

              Obx(
                () => CUploadImageBox(
                  image: controller.image.value,
                  onTap: controller.pickImage,
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
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
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