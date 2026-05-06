// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:haycrew_app/controllers/home_controller.dart';
// // import 'package:haycrew_app/pages/history/history_page.dart';
// import 'package:haycrew_app/pages/dashboard/kandang/profilepage.dart';
// import 'package:haycrew_app/constants/app_colors.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final HomeController controller = Get.find();

//     final List<Widget> pages = [HomePageKandang(), HistoryPage(), ProfilePage()];

//     return Obx(() {
//       return Scaffold(
//         body: pages[controller.currentIndex.value],

//         // Bottom Navigation
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: controller.currentIndex.value,
//           onTap: controller.changeTab,
//           backgroundColor: AppColors.blue,
//           selectedItemColor: AppColors.white,
//           unselectedItemColor: AppColors.white,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.sports),
//               label: "Home",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.history),
//               label: "History",
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//           ],
//         ),
//       );
//     });
//   }
// }
