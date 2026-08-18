import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/components/CAppBar.dart';           
import 'package:haycrew_app/components/CDateRangePicker.dart';  
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CKandang/permintaancontroller.dart';

class PermintaanKandangPage extends GetView<PermintaanController> {
  PermintaanKandangPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CAppBar(
        title: 'Permintaan\nDana / Barang',
        multiLineTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Obx(
              () => CDateRangePicker(
                displayText: controller.formattedDate.value,
                onTap: controller.onTapDatePicker,
              ),
            ),
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

            _SubmitButton(formKey: _formKey),
            const SizedBox(height: 24),
          ],
          ),
        ),
      ),
    );
  }
}

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

class _KeperluanField extends GetView<PermintaanController> {
  const _KeperluanField();

  @override
  Widget build(BuildContext context) {
    return CTextField(
      controller: controller.keperluanController,
      hintText: 'Contoh: Sekam',
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Keperluan wajib diisi' : null,
    );
  }
}

class _NominalLabelObs extends GetView<PermintaanController> {
  const _NominalLabelObs();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _SectionLabel(text: controller.nominalLabel));
  }
}

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
          validator: (v) {
            final label = controller.nominalLabel.replaceAll('*', '');
            if (v == null || v.trim().isEmpty) return '$label wajib diisi';
            final n = int.tryParse(v.trim().replaceAll('.', ''));
            if (n == null || n <= 0) return '$label harus lebih dari 0';
            return null;
          },
        ),
      ),
    );
  }
}

class _KeteranganField extends GetView<PermintaanController> {
  const _KeteranganField();

  @override
  Widget build(BuildContext context) {
    return CTextField(
      controller: controller.keteranganController,
      hintText: '',
      maxLines: 5,
    );
  }
}

class _SubmitButton extends GetView<PermintaanController> {
  final GlobalKey<FormState> formKey;
  const _SubmitButton({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CButton(
        text:         controller.isLoading.value ? 'Mengirim...' : 'Kirim',
        onPressed:    controller.isLoading.value
            ? null
            : () {
                if (formKey.currentState?.validate() ?? false) {
                  controller.submit();
                }
              },
        color:        AppColors.primaryGreen,
        fontSize:     16,
        fontWeight:   FontWeight.w600,
        borderRadius: 8,
      ),
    );
  }
}