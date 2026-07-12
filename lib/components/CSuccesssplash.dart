import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// CSuccessSplash — Layar hijau full-screen dengan icon checklist bulat +
/// pesan, muncul sesaat setelah submit berhasil, lalu hilang sendiri.
///
/// Cara pakai (di controller, setelah submit sukses):
/// ```dart
/// await CSuccessSplash.show(message: 'Laporan berhasil\ntersimpan');
/// Get.back(); // balik ke halaman sebelumnya setelah splash selesai
/// ```
class CSuccessSplash extends StatelessWidget {
  final String message;

  const CSuccessSplash({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primaryGreen,
                  size: 50,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilkan splash full-screen selama [duration], lalu otomatis tertutup.
  /// Widget ini pakai [Get.dialog] tanpa barrier (`barrierDismissible: false`,
  /// `useSafeArea: false`) supaya benar-benar menutupi seluruh layar termasuk
  /// area status bar, dan user tidak bisa tap-to-close di tengah proses.
  static Future<void> show({
    String message = 'Berhasil\ntersimpan',
    Duration duration = const Duration(seconds: 2),
  }) async {
    Get.dialog(
      CSuccessSplash(message: message),
      barrierDismissible: false,
      useSafeArea: false,
    );

    await Future.delayed(duration);

    // Tutup splash-nya sebelum lanjut ke navigasi berikutnya.
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}