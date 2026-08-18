import 'package:flutter/material.dart';

enum RiwayatType { permintaan, laporanKandang, laporanGudang, tambahStok }


class RiwayatItem {
  final String id;
  final RiwayatType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final bool isPending;
  final String? alasan; // optional alasan penolakan / catatan tambahan

  const RiwayatItem({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    this.isPending = false,
    this.alasan,
  });
}