import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/components/CStokItemCard.dart';
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
// SUMMARY ROW — Stok Ayam (ekor) | Stok Keluar (ekor)
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
                label: 'Stok Ayam (ekor)',
                value: controller.stokAyamGudang.value.toString(),
                color: AppColors.primaryGreen,
                icon: Icons.egg_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Stok Keluar (ekor)',
                value: controller.stokKeluar.value.toString(),
                color: AppColors.orange,
                icon: Icons.local_shipping_outlined,
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
        return const CLoadingOrEmpty.loading();
      }

      // State 2: kosong
      if (controller.stokList.isEmpty) {
        return const CLoadingOrEmpty.empty(
          message: 'Tidak ada data stok',
          icon: Icons.inventory_2_outlined,
        );
      }

      // State 3: ada data
      return Column(
        children: controller.stokList.map((item) {
          return CStokItemCard(
            item: item,
            onTap: () => controller.navigateToDetail(item),
          );
        }).toList(),
      );
    });
  }
}