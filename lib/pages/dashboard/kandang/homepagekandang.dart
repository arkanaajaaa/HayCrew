import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CButton.dart';
import '../../../constants/api_constant.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/home_controller.dart';
import '../../../components/calender_widget.dart';
import '../../../components/status_card_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/notifikasi_controller.dart';

class HomePageKandang extends StatefulWidget {
  const HomePageKandang({super.key});

  @override
  State<HomePageKandang> createState() => _HomePageKandangState();
}

class _HomePageKandangState extends State<HomePageKandang> {
  final _calendarKey = GlobalKey<CalendarWidgetState>();
  late final HomeController _controller;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _pollTimer = Timer.periodic(ApiConstant.pollInterval, (_) {
      _controller.loadStatusPermintaan(showLoading: false);
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
            _HomeHeader(controller: _controller),
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
                        onDateSelected: (date) =>
                            debugPrint('Selected date: $date'),
                        token: _controller.token,
                      ),
                      _HomeActionButtons(controller: _controller),
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
                      _HomeStatusList(controller: _controller),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
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

class _HomeActionButtons extends StatelessWidget {
  final HomeController controller;

  const _HomeActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _HomeStatusList extends StatelessWidget {
  final HomeController controller;

  const _HomeStatusList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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

      const int maxVisible = 8;
      final visibleStatusList = controller.statusList.take(maxVisible).toList();
      return Column(
        children: visibleStatusList.map((status) {
          return StatusCardWidget(
            status: status,
            onTap: () => controller.navigateToDetail(status),
          );
        }).toList(),
      );
    });
  }
}