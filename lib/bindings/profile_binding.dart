import 'package:get/get.dart';
import 'package:haycrew_app/controllers/profilecontroller.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfilController());
  }
}