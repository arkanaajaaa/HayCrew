import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/constants/app_colors.dart';
import 'package:haycrew_app/controllers/profilecontroller.dart';

class ProfilPage extends GetView<ProfilController> {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const _AvatarWidget(),
              const SizedBox(height: 20),
              Obx(
                () => Text(
                  controller.userName.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => Text(
                  controller.userRole.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: controller.statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: controller.statusColor,
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.isLoadingProfile.value) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (controller.hasProfileError.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton.icon(
                      onPressed: controller.fetchProfile,
                      icon: const Icon(Icons.refresh, size: 16, color: AppColors.red),
                      label: const Text(
                        'Gagal memuat data. Coba lagi',
                        style: TextStyle(color: AppColors.red, fontSize: 12),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              const _DetailKaryawanSection(),
              const SizedBox(height: 24),
              _ProfileActionButton(
                icon: Icons.help_outline,
                label: 'Pusat Bantuan',
                onTap: controller.onTapPusatBantuan,
              ),
              const SizedBox(height: 14),
              _ProfileActionButton(
                icon: Icons.logout,
                label: 'Keluar',
                onTap: controller.onTapKeluar,
                isDanger: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Profil',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AvatarWidget extends GetView<ProfilController> {
  const _AvatarWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: ClipOval(
        child: Obx(() {
          final url = controller.userPhotoUrl.value;
          if (url == null || url.isEmpty) {
            return Container(
              color: AppColors.calendarBackground,
              child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 56),
            );
          }
          return Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.calendarBackground,
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.calendarBackground,
              child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 56),
            ),
          );
        }),
      ),
    );
  }
}

class _DetailKaryawanSection extends GetView<ProfilController> {
  const _DetailKaryawanSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = <MapEntry<String, String>>[
        if ((controller.userEmail.value ?? '').isNotEmpty)
          MapEntry('Email', controller.userEmail.value!),
        if ((controller.userPhone.value ?? '').isNotEmpty)
          MapEntry('No. HP', controller.userPhone.value!),
        if (controller.joinDate.value != null) MapEntry('Bergabung', controller.joinDate.value!),
        if (controller.tempatLahir.value != null)
          MapEntry('Tempat Lahir', controller.tempatLahir.value!),
        if (controller.tanggalLahir.value != null)
          MapEntry('Tanggal Lahir', controller.tanggalLahir.value!),
        if (controller.jenisKelamin.value != null)
          MapEntry('Jenis Kelamin', controller.jenisKelamin.value!),
      ];

      if (rows.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          children: rows.map((entry) {
            final isLast = entry == rows.last;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  Flexible(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.red : AppColors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDanger ? AppColors.red.withOpacity(0.4) : Colors.black,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}