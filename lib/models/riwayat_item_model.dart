import 'package:flutter/material.dart';

enum RiwayatType { permintaan, laporanKandang, laporanGudang, tambahStok }

/// Satu baris aktivitas di halaman Riwayat — hasil gabungan dari beberapa
/// jenis data (permintaan, laporan, dst) yang dipersonalisasi per user oleh
/// controller masing-masing (data yang dipakai di sini sudah difilter milik
/// user yang login, bukan seluruh tim).
class RiwayatItem {
  final String id;
  final RiwayatType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final bool isPending;

  const RiwayatItem({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    this.isPending = false,
  });
}
