import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/home_controller.dart';
import '../../../components/calender_widget.dart';
import '../../../components/status_card_widget.dart';
import '../../../components/CNavbar.dart'; // Import komponen baru

class HomePageKandang extends StatelessWidget {
  final String? userName;
  final String? userRole;

  const HomePageKandang({
    Key? key,
    this.userName,
    this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalendarWidget(
                        onDateSelected: (date) => print('Selected date: $date'),
                        enableGoogleCalendar: true,
                      ),
                      _buildActionButtons(controller),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Status Permintaan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatusList(controller),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Cukup panggil komponen reusable di sini
      bottomNavigationBar: const CBottomNav(),
    );
  }

  // --- Widget Helper (Semua tetap utuh sesuai kode awalmu) ---

  Widget _buildHeader(HomeController controller) {
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
                    const Text('Halo, ', style: TextStyle(fontSize: 28, color: AppColors.primaryGreen)),
                    Flexible(
                      child: Text(
                        userName ?? controller.userName ?? 'User',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(userRole ?? controller.userRole ?? 'Karyawan', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryGreen, size: 24),
              onPressed: controller.navigateToNotifications,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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

  Widget _buildStatusList(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
  child: Padding(
    padding: EdgeInsets.all(32),
    child: CircularProgressIndicator(),
  ),
);
      }
      if (controller.statusList.isEmpty) {
        return Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min, // Tambahkan ini agar Column tidak memakan semua ruang vertikal
      children: [
        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Tidak ada status permintaan',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    ),
  ),
);
      }
      return Column(
        children: controller.statusList.map((status) {
          return StatusCardWidget(status: status, onTap: () => controller.navigateToDetail(status));
        }).toList(),
      );
    });
  }
}