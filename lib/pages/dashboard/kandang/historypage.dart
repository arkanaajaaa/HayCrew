// lib/pages/dashboard/kandang/historypage.dart
import 'package:flutter/material.dart';
import 'package:haycrew_app/constants/app_colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Fitur Riwayat\nakan segera tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}