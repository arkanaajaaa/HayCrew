import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/notifikasi_controller.dart';

class NotifikasiPage extends GetView<NotifikasiController> {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CAppBar(
        title: 'Notifikasi',
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text(
              'Tandai dibaca',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchNotifikasi(showLoading: false),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CLoadingOrEmpty.loading();
          }
          if (controller.notifikasiList.isEmpty) {
            return const CLoadingOrEmpty.empty(
              message: 'Belum ada notifikasi',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifikasiList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final event = controller.notifikasiList[index];
              final read = controller.isRead(event.id);
              return InkWell(
                onTap: () => controller.markAsRead(event.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: read ? Colors.white : AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textFieldBg.withOpacity(0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 10, top: 5),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(event.date),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (event.description != null && event.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(event.description!, style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}