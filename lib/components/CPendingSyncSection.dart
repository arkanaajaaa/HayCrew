import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CPendingSyncItem {
  final int id;
  final String title;
  final String subtitle;

  const CPendingSyncItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}


class CPendingSyncSection extends StatelessWidget {
  final List<CPendingSyncItem> items;
  final bool Function(int id) isSyncing;
  final void Function(int id) onRetry;
  final void Function(int id) onDelete;

  const CPendingSyncSection({
    super.key,
    required this.items,
    required this.isSyncing,
    required this.onRetry,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context, CPendingSyncItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text('Hapus "${item.title}" yang tersimpan lokal ini? Data yang belum sempat terkirim akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete(item.id);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_off, size: 18, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${items.length} laporan tersimpan lokal, belum terkirim',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Text(
                          item.subtitle,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (isSyncing(item.id))
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.sync, size: 20, color: AppColors.primaryGreen),
                      tooltip: 'Coba kirim lagi',
                      onPressed: () => onRetry(item.id),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      tooltip: 'Hapus',
                      onPressed: () => _confirmDelete(context, item),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
