import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CStorage/laporanstok_controller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/CDaterangepicker.dart';
import 'package:haycrew_app/components/CUploadimagepage.dart';
import '../../../constants/app_colors.dart';

class LaporanStokPage extends GetView<LaporanStokController> {
  const LaporanStokPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CAppBar(title: 'Laporan\nGudang', multiLineTitle: true),
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
              const SizedBox(height: 18),

              Text('Jumlah daging jual*', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: CTextField(
                      controller: controller.jumlahDagingJualController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ekor'),
                ],
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