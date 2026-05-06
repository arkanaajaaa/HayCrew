// lib/controllers/navbar_controller.dart
import 'package:get/get.dart';

class NavbarController extends GetxController {
  var currentNavIndex = 0.obs;

  void changeTab(int index) {
    currentNavIndex.value = index;
  }
}