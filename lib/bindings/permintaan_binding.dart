import 'package:get/get.dart';
import 'package:haycrew_app/controllers/CKandang/permintaancontroller.dart';

class PermintaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermintaanController());
  }
}