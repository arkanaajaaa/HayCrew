import 'package:flutter/material.dart';
import '../models/status_permintaan_model.dart';
import '../constants/app_colors.dart';

/// Widget untuk menampilkan card status permintaan
/// Reusable component yang bisa dipanggil dari mana saja
class StatusCardWidget extends StatelessWidget {
  final StatusPermintaanModel status;
  final VoidCallback? onTap;

  const StatusCardWidget({
    Key? key,
    required this.status,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getStatusColor(status.status),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date Section
            _buildDateSection(),
            
            const SizedBox(width: 20),
            
            // Content Section
            Expanded(
              child: _buildContentSection(),
            ),
            
            const SizedBox(width: 12),
            
            // Status Badge
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  /// Build date section (day & month)
  Widget _buildDateSection() {
    return Column(
      children: [
        Text(
          status.day.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status.month,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build content section (title & subtitle)
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (status.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            status.subtitle!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status.status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Get color based on status
  Color _getStatusColor(StatusType type) {
    switch (type) {
      case StatusType.accepted:
        return AppColors.lightGreen;
      case StatusType.pending:
        return AppColors.orange;
      case StatusType.rejected:
        return AppColors.red;
    }
  }

  /// Get label text based on status
  String _getStatusLabel(StatusType type) {
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