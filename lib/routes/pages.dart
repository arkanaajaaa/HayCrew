import 'package:get/get.dart';
import 'package:haycrew_app/bindings/LoginBinding.dart';
import 'package:haycrew_app/pages/login_page/login_mobile.dart';
import 'package:haycrew_app/routes/routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.loginPage,
      page: () => LoginMobile(),
      binding: LoginBinding(),
    ),
];
}
