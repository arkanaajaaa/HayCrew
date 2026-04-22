import 'package:get/get.dart';

class NavbarController extends GetxController {
  // .obs membuat variabel ini reaktif
  var currentNavIndex = 0.obs;

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    
    // Kamu bisa menambahkan logika navigasi halaman di sini jika perlu
    // Contoh: if(index == 1) Get.toNamed('/history');
  }
}