import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CAppbar.dart';
import 'package:haycrew_app/components/Cloadingorempty.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';

class RiwayatStoragePage extends StatefulWidget {
  const RiwayatStoragePage({Key? key}) : super(key: key);

  @override
  State<RiwayatStoragePage> createState() => _RiwayatStoragePageState();
}

class _RiwayatStoragePageState extends State<RiwayatStoragePage> {
  final StorageHomeController controller = Get.find<StorageHomeController>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StokItemModel> _filtered(List<StokItemModel> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((s) =>
            s.jenis.toLowerCase().contains(q) ||
            (s.picName ?? '').toLowerCase().contains(q))
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
                hintText: 'Cari jenis stok atau PIC...',
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
                if (controller.isLoading.value && controller.stokList.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      CLoadingOrEmpty.loading(),
                    ],
                  );
                }

                final items = _filtered(controller.stokList);

                if (items.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      CLoadingOrEmpty.empty(
                        message: _query.trim().isEmpty
                            ? 'Belum ada riwayat stok'
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
                    final item = items[index];
                    return _RiwayatStorageCard(
                      item: item,
                      onTap: () => controller.navigateToDetail(item),
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