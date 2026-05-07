/// lib/pages/dashboard/storage/homepagestorage.dart
///
/// Struktur mengikuti homepagekandang.dart:
///   Scaffold
///     ├── _StorageHeader  (salam + nama + notif)
///     ├── _StorageSummaryRow  (kartu ringkasan stok)
///     ├── _StorageActionButtons  (Tambah Stok | Laporan Stok)
///     └── _StorageStokList  (daftar item stok)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';

class HomePageStorage extends StatelessWidget {
  const HomePageStorage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorageHomeController controller =
        Get.find<StorageHomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StorageHeader(controller: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _StorageSummaryRow(controller: controller),
                      const SizedBox(height: 16),
                      _StorageActionButtons(controller: controller),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Daftar Stok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StorageStokList(controller: controller),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER — sama persis strukturnya dengan _HomeHeader di homepagekandang
// ═══════════════════════════════════════════════════════════════════════════

class _StorageHeader extends StatelessWidget {
  final StorageHomeController controller;
  const _StorageHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Halo, ',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Flexible(
                      child: Obx(
                        () => Text(
                          controller.userName.value,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.userRole.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              onPressed: controller.navigateToNotifications,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY ROW — 3 kartu: Total | Menipis | Habis
// ═══════════════════════════════════════════════════════════════════════════

class _StorageSummaryRow extends StatelessWidget {
  final StorageHomeController controller;
  const _StorageSummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Item',
                value: controller.totalItem.toString(),
                color: AppColors.primaryGreen,
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Menipis',
                value: controller.itemMenipis.toString(),
                color: AppColors.orange,
                icon: Icons.warning_amber_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Habis',
                value: controller.itemHabis.toString(),
                color: AppColors.red,
                icon: Icons.remove_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTION BUTTONS — Tambah Stok | Laporan Stok
// Menggunakan CButton yang sama seperti di homepagekandang
// ═══════════════════════════════════════════════════════════════════════════

class _StorageActionButtons extends StatelessWidget {
  final StorageHomeController controller;
  const _StorageActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CButton(
              text: 'Tambah Stok',
              fontSize: 12,
              icon: Icons.add_box_outlined,
              height: 60,
              color: AppColors.primaryGreen,
              onPressed: controller.navigateToTambahStok,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CButton(
              text: 'Laporan Stok',
              fontSize: 12,
              icon: Icons.bar_chart_outlined,
              height: 60,
              color: AppColors.primaryGreen,
              onPressed: controller.navigateToLaporanStok,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STOK LIST — daftar item stok dengan indikator warna status
// Pola Obx loading/empty/data sama persis dengan _HomeStatusList
// ═══════════════════════════════════════════════════════════════════════════

class _StorageStokList extends StatelessWidget {
  final StorageHomeController controller;
  const _StorageStokList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // State 1: loading
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      // State 2: kosong
      if (controller.stokList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada data stok',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      // State 3: ada data
      return Column(
        children: controller.stokList.map((item) {
          return _StokItemCard(
            item: item,
            onTap: () => controller.navigateToDetail(item),
          );
        }).toList(),
      );
    });
  }
}

// ─── Kartu item stok ──────────────────────────────────────────────────────

class _StokItemCard extends StatelessWidget {
  final StokItemModel item;
  final VoidCallback? onTap;

  const _StokItemCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon status
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(item.status), color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Nama & jumlah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.jumlah} ${item.satuan}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Badge status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(item.status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aman':    return AppColors.lightGreen;
      case 'menipis': return AppColors.orange;
      case 'habis':   return AppColors.red;
      default:        return AppColors.primaryGreen;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'aman':    return Icons.check_circle_outline;
      case 'menipis': return Icons.warning_amber_outlined;
      case 'habis':   return Icons.remove_circle_outline;
      default:        return Icons.help_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aman':    return 'Aman';
      case 'menipis': return 'Menipis';
      case 'habis':   return 'Habis';
      default:        return status;
    }
  }
}