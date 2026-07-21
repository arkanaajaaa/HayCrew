import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  final bool multiLineTitle;

  const CAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor = AppColors.white,
    this.titleColor = AppColors.primaryGreen,
    this.actions,
    this.onBackPressed,
    this.multiLineTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: titleColor,
          fontSize: multiLineTitle ? 20 : 22,
          fontWeight: FontWeight.w600,
          height: multiLineTitle ? 1.3 : null,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: titleColor),
              onPressed: onBackPressed ?? Get.back,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}