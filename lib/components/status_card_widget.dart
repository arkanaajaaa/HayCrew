import 'package:flutter/material.dart';
import '../models/status_permintaan_model.dart';
import '../constants/app_colors.dart';

class StatusCardWidget extends StatelessWidget {
  final StatusPermintaanModel status;
  final VoidCallback? onTap;

  const StatusCardWidget({Key? key, required this.status, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(20),
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
          children: [

            _buildDateSection(),

            const SizedBox(width: 20),


            Expanded(child: _buildContentSection()),

            const SizedBox(width: 12),


            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }


  Widget _buildDateSection() {
    return Column(
      children: [
        Text(
          status.day.toString(),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status.month,
          style: TextStyle(
            color: AppColors.textDark.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.title,
          style: const TextStyle(
            color: AppColors.textDark,
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
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }


  Widget _buildStatusBadge() {
    final color = _getStatusColor(status.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status.status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


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