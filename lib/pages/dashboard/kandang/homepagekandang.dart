import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/home_controller.dart';
import '../../../components/calender_widget.dart';
import '../../../components/status_card_widget.dart';

class HomePageKandang extends StatelessWidget {
  const HomePageKandang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HomeHeader(controller: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalendarWidget(
                        onDateSelected: (date) =>
                            print('Selected date: $date'),
                        enableGoogleCalendar: true,
                      ),
                      _HomeActionButtons(controller: controller),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Status Permintaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HomeStatusList(controller: controller),
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

/// Header bagian atas halaman beranda.
/// Menampilkan salam + nama user + role + tombol notifikasi.
/// Menggunakan Obx agar nama & role langsung update
/// jika HomeController mengubah nilainya.
class _HomeHeader extends StatelessWidget {
  final HomeController controller;

  const _HomeHeader({required this.controller});

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
          // Bagian kiri: salam + nama + role
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
                        // Obx memantau userName agar teks langsung
                        // berubah tanpa perlu rebuild seluruh halaman
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bagian kanan: tombol notifikasi
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

/// Dua tombol aksi utama di halaman beranda.
/// Menggunakan CButton dari components/CButton.dart.
/// Masing-masing memanggil fungsi navigasi di HomeController
/// yang melakukan Get.toNamed ke route LaporanPage / PermintaanPage.
class _HomeActionButtons extends StatelessWidget {
  final HomeController controller;

  const _HomeActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Tombol kiri — navigasi ke LaporanPage
          Expanded(
            child: CButton(
              text: 'Lapor Kandang',
              fontSize: 12,
              icon: Icons.assignment_outlined,
              height: 60,
              color: AppColors.primaryGreen,
              onPressed: controller.navigateToLaporKandang,
            ),
          ),
          const SizedBox(width: 12),
          // Tombol kanan — navigasi ke PermintaanPage
          Expanded(
            child: CButton(
              text: 'Kirim Permintaan',
              fontSize: 12,
              icon: Icons.send_outlined,
              height: 60,
              color: AppColors.primaryGreen,
              onPressed: controller.navigateToKirimPermintaan,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar kartu status permintaan.
/// Menggunakan StatusCardWidget dari components/status_card_widget.dart.
///
/// Obx di sini memantau dua observable dari HomeController:
/// - isLoading  → tampilkan CircularProgressIndicator
/// - statusList → tampilkan daftar kartu atau pesan kosong
class _HomeStatusList extends StatelessWidget {
  final HomeController controller;

  const _HomeStatusList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // State 1: sedang loading data dari API
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          ),
        );
      }

      // State 2: data kosong (belum ada permintaan)
      if (controller.statusList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada status permintaan',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // State 3: ada data — tampilkan daftar StatusCardWidget
      // StatusCardWidget sudah reusable dari components/status_card_widget.dart
      // onTap memanggil navigateToDetail yang menampilkan AlertDialog
      return Column(
        children: controller.statusList.map((status) {
          return StatusCardWidget(
            status: status,
            onTap: () => controller.navigateToDetail(status),
          );
        }).toList(),
      );
    });
  }
}