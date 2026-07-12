import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// CUploadImageBox — Kotak upload gambar dengan border putus-putus (dashed),
/// preview foto, dan placeholder icon + text. Dipakai di TambahStokPage &
/// LaporanStokPage (dan bisa dipakai ulang di halaman lain yang butuh upload foto).
///
/// Penggunaan:
/// ```dart
/// Obx(() => CUploadImageBox(
///   image: controller.image.value,
///   onTap: controller.pickImage,
/// ))
/// ```
class CUploadImageBox extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final double height;
  final String title;
  final String subtitle;

  const CUploadImageBox({
    Key? key,
    required this.image,
    required this.onTap,
    this.height = 160,
    this.title = 'Unggah Gambar',
    this.subtitle = 'Klik untuk mengambil foto atau mengunggah dari galeri',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _DashedBorderPainter(color: AppColors.primaryGreen),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: height,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primaryGreen,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Painter border putus-putus (dashed) rounded-rect, tanpa perlu tambah
/// package baru ke pubspec.yaml.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    this.radius = 12,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _dashPath(path, dashWidth: dashWidth, dashGap: dashGap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, {required double dashWidth, required double dashGap}) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        dest.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}