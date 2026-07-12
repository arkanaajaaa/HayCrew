import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CStorage/laporanstok_controller.dart';

class LaporanStokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LaporanStokController());
  }
}