import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/components/CStokItemCard.dart';
import 'package:haycrew_app/components/calender_widget.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/notifikasi_controller.dart';

class HomePageStorage extends StatefulWidget {
  const HomePageStorage({super.key});

  @override
  State<HomePageStorage> createState() => _HomePageStorageState();
}

class _HomePageStorageState extends State<HomePageStorage> {
  final _calendarKey = GlobalKey<CalendarWidgetState>();
  late final StorageHomeController _controller;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<StorageHomeController>();
    _pollTimer = Timer.periodic(ApiConstant.pollInterval, (_) {
      _controller.refreshData(showLoading: false);
      _calendarKey.currentState?.refresh();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StorageHeader(controller: _controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalendarWidget(
                        key: _calendarKey,
                        token: _controller.token,
                      ),
                      _GudangFilterRow(controller: _controller),
                      const SizedBox(height: 12),
                      _StorageSummaryRow(controller: _controller),
                      const SizedBox(height: 16),
                      _StorageActionButtons(controller: _controller),
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
                      _StorageStokList(controller: _controller),
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
          Obx(() {
            final unread = Get.find<NotifikasiController>().unreadCount;
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: AppColors.primaryGreen),
                    if (unread > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GudangFilterRow extends StatelessWidget {
  final StorageHomeController controller;
  const _GudangFilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = controller.gudangFilterOptions;
      if (options.length <= 1) return const SizedBox.shrink();

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final name = options[index];
            // Obx per-chip (bukan cuma satu Obx di luar) karena ListView.
            // separated ngerender itemBuilder secara lazy di luar siklus
            // build Obx terluar — kalau selectedGudang cuma dibaca di sini
            // tanpa Obx sendiri, GetX nggak pernah "lihat" dependency-nya
            // jadi highlight chip nggak pernah update pas ditap.
            return Obx(() {
              final isSelected = controller.selectedGudang.value == name;
              return InkWell(
                onTap: () => controller.setGudangFilter(name),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : AppColors.textFieldBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }
}

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
    // Card netral (senada sama CalendarWidget/StatusCardWidget/CStokItemCard)
    // dengan aksen warna cuma di ikon & angka — biar semua card di halaman
    // ini kerasa satu keluarga visual, bukan blok warna sendiri-sendiri.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textFieldBg.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textFieldBg.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
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


class _StorageStokList extends StatelessWidget {
  final StorageHomeController controller;
  const _StorageStokList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (controller.isLoading.value) {
        return const CLoadingOrEmpty.loading();
      }


      if (controller.hasLoadError.value) {
        return CLoadingOrEmpty.error(
          message: 'Gagal memuat data stok',
          errorDetail: 'Cek koneksi internet kamu lalu coba lagi.',
          onRetry: () => controller.loadStok(),
        );
      }


      if (controller.stokList.isEmpty) {
        return const CLoadingOrEmpty.empty(
          message: 'Tidak ada data stok',
          icon: Icons.inventory_2_outlined,
        );
      }


      const int maxVisible = 8;
      final visibleStokList = controller.stokList.take(maxVisible).toList();
      return Column(
        children: visibleStokList.map((item) {
          return CStokItemCard(
            item: item,
            onTap: () => controller.navigateToDetail(item),
          );
        }).toList(),
      );
    });
  }
}