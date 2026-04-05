// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:haycrew_app/constants/app_colors.dart'; // Ubah jika path berbeda
// import 'package:haycrew/controllers/splashscreen_controller.dart';

// class SplashscreenPage extends StatelessWidget {
//   const SplashscreenPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SplashscreenController controller = Get.find();

//     return Scaffold(
//       backgroundColor: AppColors.background, // Ganti dengan warna dari constants.dart
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/images/logo_haytung.png',
//               width: 120,
//               height: 120,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "HayCrew",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 40),
//             CircularProgressIndicator(
//               color: AppColors.accent,
//               strokeWidth: 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }