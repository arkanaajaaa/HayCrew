import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginResponsiveController extends GetxController {
 var isMobile = true.obs;

updateLayout(BoxConstraints constraints) {
  isMobile.value = constraints.maxWidth < 600;
}
}