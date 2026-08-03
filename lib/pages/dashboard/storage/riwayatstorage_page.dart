// lib/pages/dashboard/storage/riwayatstorage_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';

/// Riwayat Storage — menampilkan seluruh data Daftar Stok.
/// Reuse 100% dari [StorageHomeController.stokList] (endpoint `/api/stok`),
class RiwayatStoragePage extends GetView<StorageHomeController> {
  const RiwayatStoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CAppBar(title: 'Riwayat Kegiatan'),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.refreshData,
        child: Obx(() {
          if (controller.isLoading.value && controller.stokList.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                CLoadingOrEmpty.loading(),
              ],
            );
          }

          if (controller.stokList.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                CLoadingOrEmpty.empty(
                  message: 'Belum ada riwayat stok',
                  icon: Icons.history,
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: controller.stokList.length,
            itemBuilder: (context, index) {
              final item = controller.stokList[index];
              return _RiwayatStorageCard(
                item: item,
                onTap: () => controller.navigateToDetail(item),
              );
            },
          );
        }),
      ),
    );
  }
}

class _RiwayatStorageCard extends StatelessWidget {
  final StokItemModel item;
  final VoidCallback onTap;

  const _RiwayatStorageCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama stok, jumlah, berat, info lain
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.jenis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.jumlahStok} pcs • ${_formatBerat(item.beratPerItem)} kg/item',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Total: ${_formatBerat(item.estimasiTotalBerat)} kg',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (item.tanggalUpdate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Diperbaharui: ${item.tanggalUpdate}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                  if ((item.picName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'PIC: ${item.picName}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(item.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBerat(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aman':
        return AppColors.lightGreen;
      case 'waspada':
        return AppColors.orange;
      case 'tidak aman':
        return AppColors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aman':
        return 'Aman';
      case 'waspada':
        return 'Waspada';
      case 'tidak aman':
        return 'Tidak Aman';
      default:
        return status;
    }
  }
}