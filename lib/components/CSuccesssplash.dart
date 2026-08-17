import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

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

  
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}