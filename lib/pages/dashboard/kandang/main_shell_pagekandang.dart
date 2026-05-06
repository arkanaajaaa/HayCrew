// lib/pages/dashboard/kandang/main_shell_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/navbar_controller.dart';
import 'package:haycrew_app/pages/dashboard/kandang/homepagekandang.dart';
import 'package:haycrew_app/pages/dashboard/kandang/historypage.dart';
import 'package:haycrew_app/pages/dashboard/kandang/profilepage.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavbarController navController = Get.find<NavbarController>();

    // Tiga halaman yang di-swap di body
    final List<Widget> pages = [
      const HomePageKandang(),
      const HistoryPage(),
      const ProfilPage(),
    ];

    return Obx(() {
      return Scaffold(
        // Body langsung swap berdasarkan index — tidak ada navigasi route
        body: pages[navController.currentNavIndex.value],

        bottomNavigationBar: _buildBottomNav(navController),
      );
    });
  }

  Widget _buildBottomNav(NavbarController navController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Beranda',
                index: 0,
                currentIndex: navController.currentNavIndex.value,
                onTap: () => navController.changeTab(0),
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'Riwayat',
                index: 1,
                currentIndex: navController.currentNavIndex.value,
                onTap: () => navController.changeTab(1),
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profil',
                index: 2,
                currentIndex: navController.currentNavIndex.value,
                onTap: () => navController.changeTab(2),
              ),
            ],
          ),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}