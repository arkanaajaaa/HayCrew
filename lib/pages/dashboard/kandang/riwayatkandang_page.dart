import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CKandang/riwayat_kandang_controller.dart';
import 'package:haycrew_app/models/riwayat_item_model.dart';

class RiwayatKandangPage extends StatefulWidget {
  const RiwayatKandangPage({Key? key}) : super(key: key);

  @override
  State<RiwayatKandangPage> createState() => _RiwayatKandangPageState();
}

class _RiwayatKandangPageState extends State<RiwayatKandangPage> {
  final RiwayatKandangController controller = Get.find<RiwayatKandangController>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RiwayatItem> _filtered(List<RiwayatItem> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CAppBar(title: 'Riwayat Kegiatan', showBackButton: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Cari aktivitas...',
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                isDense: true,
                filled: true,
                fillColor: AppColors.textFieldBg.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: controller.fetchRiwayat,
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      CLoadingOrEmpty.loading(),
                    ],
                  );
                }

                if (controller.hasError.value) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      CLoadingOrEmpty.error(
                        message: 'Gagal memuat riwayat',
                        errorDetail: 'Cek koneksi internet kamu lalu coba lagi.',
                        onRetry: () => controller.fetchRiwayat(),
                      ),
                    ],
                  );
                }

                final items = _filtered(controller.items);

                if (items.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      CLoadingOrEmpty.empty(
                        message: _query.trim().isEmpty
                            ? 'Belum ada riwayat aktivitas'
                            : 'Gak ada hasil buat "$_query"',
                        icon: Icons.history,
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _RiwayatCard(item: items[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final RiwayatItem item;

  const _RiwayatCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case RiwayatType.permintaan:
        return Icons.request_quote_outlined;
      case RiwayatType.laporanKandang:
        return Icons.assignment_outlined;
      case RiwayatType.laporanGudang:
        return Icons.inventory_2_outlined;
      case RiwayatType.tambahStok:
        return Icons.add_box_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Card netral senada sama CalendarWidget/CStokItemCard/StatusCardWidget
    // (tint krem tipis + border + shadow halus), dengan ikon jenis aktivitas
    // dikasih badge bundar kecil — bukan lagi strip warna tebal di kiri yang
    // beda sendiri dari card-card lain di aplikasi.
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(item.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'id_ID').format(item.date),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 12),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(_icon, size: 17, color: Colors.grey[600]),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${DateFormat('dd MMM yyyy', 'id_ID').format(item.date)}'),
            const SizedBox(height: 8),
            Text('Status: ${item.statusLabel}'),
            const SizedBox(height: 8),
            Text(item.subtitle),
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Tutup'))],
      ),
    );
  }
}
