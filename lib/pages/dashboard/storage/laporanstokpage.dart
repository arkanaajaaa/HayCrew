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

  static const Color _chipBackground = Color(0xFFE3E0C8);

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
                  displayText: controller.formattedDate.value,
                  onTap: controller.selectDate,
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(theme, 'Stok Awal', required: true),
                        const SizedBox(height: 6),
                        CTextField(
                          controller: controller.stokAwalController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(theme, 'Stok Masuk', required: true),
                        const SizedBox(height: 6),
                        CTextField(
                          controller: controller.stokMasukController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildLabel(theme, 'Stok Daging', required: true),
              const SizedBox(height: 8),
              _buildStokDagingHeader(context),
              const SizedBox(height: 10),
              Obx(() => _buildStokDagingListView()),
              const SizedBox(height: 18),

              _buildLabel(theme, 'Tempat Pendistribusian', required: true),
              const SizedBox(height: 6),
              CTextField(
                controller: controller.tempatDistribusiController,
                hintText: 'Contoh : Pasar Induk',
              ),
              const SizedBox(height: 18),

              _buildLabel(theme, 'Catatan'),
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

  Widget _buildLabel(ThemeData theme, String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildStokDagingHeader(BuildContext context) {
    return Row(
      children: [
        _headerChip('Jenis'),
        const SizedBox(width: 8),
        _headerChip('Bobot'),
        const SizedBox(width: 8),
        _headerChip('Jumlah'),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showAddStokDagingSheet(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _chipBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }

  Widget _headerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _chipBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStokDagingListView() {
    final items = controller.stokDagingList;

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Belum ada data stok daging. Tap "+" untuk menambah.',
          style: TextStyle(color: Colors.black45, fontSize: 13),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        final bobotText = item.bobot
            .toStringAsFixed(
                item.bobot.truncateToDouble() == item.bobot ? 0 : 1)
            .replaceAll('.', ',');
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 12),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          onDismissed: (_) => controller.removeStokDaging(item.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.jumlah}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item.jenis)),
                Text('$bobotText kg'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddStokDagingSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Stok Daging',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text('Jenis Daging', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),

            // Radio Button Pilihan Whole / Parting
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectedJenis.value = 'Whole',
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Whole',
                            groupValue: controller.selectedJenis.value,
                            activeColor: AppColors.primaryGreen,
                            onChanged: (val) {
                              if (val != null) controller.selectedJenis.value = val;
                            },
                          ),
                          const Text('Whole'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectedJenis.value = 'Parting',
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Parting',
                            groupValue: controller.selectedJenis.value,
                            activeColor: AppColors.primaryGreen,
                            onChanged: (val) {
                              if (val != null) controller.selectedJenis.value = val;
                            },
                          ),
                          const Text('Parting'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bobot (kg)'),
                      const SizedBox(height: 6),
                      CTextField(
                        controller: controller.bobotController,
                        hintText: '0,5',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jumlah'),
                      const SizedBox(height: 6),
                      CTextField(
                        controller: controller.jumlahController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CButton(
              text: 'Tambah',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              borderRadius: 8,
              color: AppColors.primaryGreen,
              onPressed: controller.addStokDaging,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}