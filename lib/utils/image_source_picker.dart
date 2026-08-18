import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haycrew_app/constants/app_colors.dart';

/// Bottom sheet pilih sumber foto (Kamera / Galeri). Return null kalau user
/// batal (tap di luar / geser turun).
Future<ImageSource?> pickImageSource() {
  return Get.bottomSheet<ImageSource>(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primaryGreen),
              title: const Text('Ambil Foto'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGreen),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );
}
