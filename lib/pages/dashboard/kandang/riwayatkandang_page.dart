// lib/pages/dashboard/kandang/riwayatkandang_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/home_controller.dart';
import 'package:haycrew_app/models/status_permintaan_model.dart';

/// Riwayat Kandang — menampilkan seluruh data Status Permintaan.
/// Reuse 100% dari [HomeController.statusList]
class RiwayatKandangPage extends StatefulWidget {
  const RiwayatKandangPage({Key? key}) : super(key: key);

  @override
  State<RiwayatKandangPage> createState() => _RiwayatKandangPageState();
}

class _RiwayatKandangPageState extends State<RiwayatKandangPage> {
  final HomeController controller = Get.find<HomeController>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StatusPermintaanModel> _filtered(List<StatusPermintaanModel> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            (s.description ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CAppBar(title: 'Riwayat Kegiatan'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Cari permintaan...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: controller.refreshData,
              child: Obx(() {
                if (controller.isLoading.value && controller.statusList.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      CLoadingOrEmpty.loading(),
                    ],
                  );
                }

                final items = _filtered(controller.statusList);

                if (items.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      CLoadingOrEmpty.empty(
                        message: _query.trim().isEmpty
                            ? 'Belum ada riwayat permintaan'
                            : 'Gak ada hasil buat "$_query"',
                        icon: Icons.history,
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final status = items[index];
                    return _RiwayatKandangCard(
                      status: status,
                      onTap: () => controller.navigateToDetail(status),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatKandangCard extends StatelessWidget {
  final StatusPermintaanModel status;
  final VoidCallback onTap;

  const _RiwayatKandangCard({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status.status);

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
            // Tanggal
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    status.day.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    status.month,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Nama permintaan + deskripsi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if ((status.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      status.description!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status badge — Hijau = Diterima, Kuning = Pending, Merah = Ditolak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(status.status),
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

  Color _statusColor(StatusType type) {
    switch (type) {
      case StatusType.accepted:
        return AppColors.lightGreen;
      case StatusType.pending:
        return AppColors.orange;
      case StatusType.rejected:
        return AppColors.red;
    }
  }

  String _statusLabel(StatusType type) {
    switch (type) {
      case StatusType.accepted:
        return 'Diterima';
      case StatusType.pending:
        return 'Pending';
      case StatusType.rejected:
        return 'Ditolak';
    }
  }
}