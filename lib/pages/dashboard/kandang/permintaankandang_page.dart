import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CKandang/permintaancontroller.dart';

/// PermintaanKandangPage — MURNI UI
/// Menggunakan CTextField, CButton, AppColors.
/// Tidak ada satu pun logic bisnis di file ini — semua dari PermintaanController.
class PermintaanKandangPage extends GetView<PermintaanController> {
  const PermintaanKandangPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _DateRangePickerField(),
            const SizedBox(height: 18),
            _SectionLabel(text: 'Jenis permintaan*'),
            const SizedBox(height: 8),
            _JenisPermintaanRadioGroup(),
            const SizedBox(height: 18),
            _SectionLabel(text: 'Keperluan*'),
            const SizedBox(height: 8),
            _KeperluanField(),
            const SizedBox(height: 18),
            _NominalLabelObs(),
            const SizedBox(height: 8),
            _NominalField(),
            const SizedBox(height: 18),
            _SectionLabel(text: 'Keterangan'),
            const SizedBox(height: 8),
            _KeteranganField(),
            const SizedBox(height: 32),
            _SubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Permintaan\nDana / Barang',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        onPressed: Get.back,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGET COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

/// Label judul tiap field
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }
}

/// Date range picker — tampil seperti field, onTap ke controller
class _DateRangePickerField extends GetView<PermintaanController> {
  const _DateRangePickerField();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onTapDatePicker,
      child: Obx(
        () => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.textFieldBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.formattedDateRange.value,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Icon(
                Icons.calendar_today,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Radio group Barang / Dana
class _JenisPermintaanRadioGroup extends GetView<PermintaanController> {
  const _JenisPermintaanRadioGroup();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _RadioOption(
            label:      'Barang',
            isSelected: controller.isBarangSelected,
            onTap:      () => controller.onSelectJenis(JenisPermintaan.barang),
          ),
          const SizedBox(width: 24),
          _RadioOption(
            label:      'Dana',
            isSelected: controller.isDanaSelected,
            onTap:      () => controller.onSelectJenis(JenisPermintaan.dana),
          ),
        ],
      ),
    );
  }
}

/// Satu opsi radio button — murni presentasi, tidak ada logic
class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lingkaran luar
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : Colors.grey.shade400,
                width: 2,
              ),
            ),
            // Titik dalam saat terpilih
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? AppColors.primaryGreen : AppColors.textDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Field Keperluan menggunakan CTextField
class _KeperluanField extends GetView<PermintaanController> {
  const _KeperluanField();

  @override
  Widget build(BuildContext context) {
    return CTextField(
      controller: controller.keperluanController,
      hintText:   '',
    );
  }
}

/// Label nominal reaktif — berubah teks sesuai jenis permintaan
class _NominalLabelObs extends GetView<PermintaanController> {
  const _NominalLabelObs();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _SectionLabel(text: controller.nominalLabel));
  }
}

/// Field Nominal menggunakan CTextField
/// keyboardType & inputFormatters sepenuhnya dari controller getter
class _NominalField extends GetView<PermintaanController> {
  const _NominalField();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: 200,
        child: CTextField(
          controller:      controller.nominalController,
          hintText:        controller.nominalHint,
          keyboardType:    controller.nominalKeyboardType,
          inputFormatters: controller.nominalInputFormatters,
        ),
      ),
    );
  }
}

/// Field Keterangan menggunakan CTextField dengan maxLines
class _KeteranganField extends GetView<PermintaanController> {
  const _KeteranganField();

  @override
  Widget build(BuildContext context) {
    return CTextField(
      controller: controller.keteranganController,
      hintText:   '',
      maxLines:   5,
    );
  }
}

/// Tombol Kirim menggunakan CButton
/// Teks, warna, dan callback sepenuhnya dari controller getter
class _SubmitButton extends GetView<PermintaanController> {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CButton(
        text:        controller.submitButtonText,
        onPressed:   controller.submitButtonCallback,
        color:       controller.submitButtonColor,
        fontSize:    16,
        fontWeight:  FontWeight.w600,
        borderRadius: 8,
      ),
    );
  }
}