import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CStorage/tambahstok_controller.dart';

class TambahStokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TambahStokController());
  }
}