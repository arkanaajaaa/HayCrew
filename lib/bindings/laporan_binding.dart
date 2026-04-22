import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CKandang/laporancontroller.dart';

class LaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LaporanController());
  }
}