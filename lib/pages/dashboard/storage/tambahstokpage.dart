import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CStorage/tambahstok_controller.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/CDaterangepicker.dart';
import 'package:haycrew_app/components/CDropdownfield.dart';
import 'package:haycrew_app/components/CUploadimagepage.dart';
import 'package:haycrew_app/components/CPendingSyncSection.dart';
import '../../../constants/app_colors.dart';

class TambahStokPage extends GetView<TambahStokController> {
  TambahStokPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CAppBar(title: 'Tambah Stok'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => CPendingSyncSection(
                    items: controller.pendingTambahStok.map((item) {
                      return CPendingSyncItem(
                        id: item['id'] as int,
                        title: 'Tambah Stok ${item['tanggal'] ?? ''}',
                        subtitle:
                            '${item['stok_masuk'] ?? '-'} ekor • ${item['tempat_pendistribusian'] ?? '-'}',
                      );
                    }).toList(),
                    isSyncing: (id) => controller.isSyncing.contains(id),
                    onRetry: (id) => controller.retrySync(
                      controller.pendingTambahStok.firstWhere((l) => l['id'] == id),
                    ),
                    onDelete: (id) => controller.deleteTambahStok(id),
                  )),
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v.trim()) == null) return 'Harus berupa angka';
                        return null;
                      },
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
              Obx(
                () => CDropdownField(
                  value: controller.selectedTempatDistribusi.value,
                  hintText: 'Pilih Tempat Pendistribusian',
                  items: controller.gudangOptions.toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.selectedTempatDistribusi.value = newValue;
                    }
                  },
                ),
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.submit();
                          }
                        },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          ),
        ),
      ),
    );
  }
}