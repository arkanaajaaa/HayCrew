/// lib/components/CStokItemCard.dart
///
/// CStokItemCard — kartu item stok reusable untuk dashboard Storage.
/// Dipakai di HomePageStorage dan LaporanStokPage supaya tampilan konsisten.

import 'package:flutter/material.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/CStorage/storagehome_controller.dart';

class CStokItemCard extends StatelessWidget {
  final StokItemModel item;
  final VoidCallback? onTap;

  const CStokItemCard({Key? key, required this.item, this.onTap})
      : super(key: key);

  static Color statusColor(String status) {
    switch (status) {
      case 'aman':
        return AppColors.lightGreen;
      case 'waspada':
        return AppColors.orange;
      case 'tidak aman':
        return AppColors.red;
      default:
        return AppColors.primaryGreen;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'aman':
        return Icons.check_circle_outline;
      case 'waspada':
        return Icons.warning_amber_outlined;
      case 'tidak aman':
        return Icons.remove_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  static String statusLabel(String status) {
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

  // Format sama seperti StorageHomeController._formatBerat: tanpa desimal
  // kalau bulat, satu desimal kalau tidak, pakai koma ala Indonesia.
  static String _formatBerat(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(item.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(statusIcon(item.status), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.jenis} ${_formatBerat(item.beratPerItem)} kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.jumlahStok} pcs • ${_formatBerat(item.estimasiTotalBerat)} kg',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel(item.status),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}