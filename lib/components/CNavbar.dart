import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/navbar_controller.dart';

class CBottomNav extends StatelessWidget {
  const CBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get.find() — pakai instance yang sudah ada dari HomeBinding
    // Tidak membuat instance baru setiap kali widget di-build
    final NavbarController navController = Get.find<NavbarController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset:     const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon:         Icons.home,
                label:        'Beranda',
                index:        0,
                currentIndex: navController.currentNavIndex.value,
                onTap:        () => navController.changeNavIndex(0),
              ),
              _buildNavItem(
                icon:         Icons.history,
                label:        'Riwayat',
                index:        1,
                currentIndex: navController.currentNavIndex.value,
                onTap:        () => navController.changeNavIndex(1),
              ),
              _buildNavItem(
                icon:         Icons.person,
                label:        'Profil',
                index:        2,
                currentIndex: navController.currentNavIndex.value,
                onTap:        () => navController.changeNavIndex(2),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
              size:  28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:      Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
                fontSize:   12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width:  20,
                decoration: BoxDecoration(
                  color:        AppColors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}