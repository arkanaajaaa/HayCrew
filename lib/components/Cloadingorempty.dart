import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// CLoadingOrEmpty — Reusable widget untuk state loading, kosong, dan error.
///
/// Dipakai di semua halaman yang punya list data agar konsisten.
///
/// Contoh penggunaan dengan Obx:
/// ```dart
/// Obx(() {
///   if (controller.isLoading.value) return const CLoadingOrEmpty.loading();
///   if (controller.list.isEmpty) return const CLoadingOrEmpty.empty(
///     message: 'Tidak ada data permintaan',
///   );
///   return Column(children: controller.list.map(...).toList());
/// })
/// ```
class CLoadingOrEmpty extends StatelessWidget {
  final _Type _type;
  final String? message;
  final IconData? icon;
  final String? errorDetail;

  const CLoadingOrEmpty.loading({Key? key})
      : _type = _Type.loading,
        message = null,
        icon = null,
        errorDetail = null,
        super(key: key);

  const CLoadingOrEmpty.empty({
    Key? key,
    this.message = 'Tidak ada data',
    this.icon = Icons.inbox_outlined,
  })  : _type = _Type.empty,
        errorDetail = null,
        super(key: key);

  const CLoadingOrEmpty.error({
    Key? key,
    this.message = 'Terjadi kesalahan',
    this.errorDetail,
  })  : _type = _Type.error,
        icon = Icons.error_outline,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_type) {
      case _Type.loading:
        return const CircularProgressIndicator(color: AppColors.primaryGreen);

      case _Type.empty:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message ?? 'Tidak ada data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        );

      case _Type.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Text(
              message ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.red, fontSize: 16),
            ),
            if (errorDetail != null) ...[
              const SizedBox(height: 8),
              Text(
                errorDetail!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ],
        );
    }
  }
}

enum _Type { loading, empty, error }