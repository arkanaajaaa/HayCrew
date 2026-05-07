/// lib/controllers/loginController.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/mock_auth_service.dart';

class LoginController extends GetxController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading       = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ─── Validasi input sebelum kirim ─────────────────────────────────────────

  bool _validateInput() {
    if (emailController.text.trim().isEmpty) {
      return _showError('Email tidak boleh kosong');
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return _showError('Format email tidak valid');
    }
    if (passwordController.text.isEmpty) {
      return _showError('Password tidak boleh kosong');
    }
    if (passwordController.text.length < 6) {
      return _showError('Password minimal 6 karakter');
    }
    return true;
  }

  // ─── Handle Login ─────────────────────────────────────────────────────────

  Future<void> handleLogin() async {
    if (!_validateInput()) return;

    try {
      isLoading.value = true;

      // ── Panggil MockAuthService (ganti dengan HTTP call saat production) ──
      // Saat production, ganti baris ini dengan:
      //
      // final response = await http.post(
      //   Uri.parse('https://api.haycrew.com/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'email'   : emailController.text.trim(),
      //     'password': passwordController.text,
      //   }),
      // );
      // if (response.statusCode != 200) { ... handle error ... }
      // final body     = jsonDecode(response.body);
      // final role     = body['data']['role'];
      // final name     = body['data']['name'];
      // final userId   = body['data']['id'].toString();
      // final token    = body['data']['token'];
      // await _saveToken(token); // simpan ke SharedPreferences
      //
      // Lalu panggil _navigateByRole(role, name, role, userId)
      // ────────────────────────────────────────────────────────────────────

      final user = await MockAuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      isLoading.value = false;

      if (user == null) {
        _showError('Email atau password salah');
        return;
      }

      Get.snackbar(
        'Berhasil',
        'Selamat datang, ${user.name}!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      );

      _navigateByRole(user);

    } catch (e) {
      isLoading.value = false;
      _showError('Login gagal: ${e.toString()}');
    }
  }

  // ─── Role-based Navigation ────────────────────────────────────────────────

  /// Navigasi ke dashboard yang sesuai berdasarkan role user.
  /// Saat backend sudah siap, [user] berasal dari response API, bukan mock.
  void _navigateByRole(MockUser user) {
    final args = {
      'userName': user.name,
      'userRole': user.role,
      'userId'  : user.userId,
    };

    switch (user.role) {
      case 'kandang':
        Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG, arguments: args);
        break;
      case 'storage':
        Get.offAllNamed(AppRoutes.DASHBOARD_STORAGE, arguments: args);
        break;
      case 'reseller':
        // TODO: Uncomment saat DASHBOARD_RESELLER sudah dibuat
        // Get.offAllNamed(AppRoutes.DASHBOARD_RESELLER, arguments: args);
        _showError('Dashboard Reseller belum tersedia');
        break;
      default:
        _showError('Role tidak dikenali: ${user.role}');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void handleForgotPassword() {
    Get.snackbar('Info', 'Fitur reset password akan segera tersedia',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10));
  }

  bool _showError(String message) {
    Get.snackbar('Error', message,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10));
    return false;
  }
}















// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../routes/app_routes.dart';

// /// LoginController
// /// Handles login state & navigasi berdasarkan role dari backend.
// /// Saat backend sudah siap, ganti bagian TODO dengan actual API call.
// class LoginController extends GetxController {
//   // ─── Text Controllers ─────────────────────────────────────────────────────
//   final emailController    = TextEditingController();
//   final passwordController = TextEditingController();

//   // ─── Observable State ─────────────────────────────────────────────────────
//   final isLoading       = false.obs;
//   final obscurePassword = true.obs;

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }

//   // ─── Actions ──────────────────────────────────────────────────────────────

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   bool validateInput() {
//     if (emailController.text.trim().isEmpty) {
//       return _showError('Email tidak boleh kosong');
//     }
//     if (!GetUtils.isEmail(emailController.text.trim())) {
//       return _showError('Format email tidak valid');
//     }
//     if (passwordController.text.isEmpty) {
//       return _showError('Password tidak boleh kosong');
//     }
//     if (passwordController.text.length < 6) {
//       return _showError('Password minimal 6 karakter');
//     }
//     return true;
//   }

//   Future<void> handleLogin() async {
//     if (!validateInput()) return;

//     try {
//       isLoading.value = true;

//       // ── TODO: Ganti dengan actual API call ──────────────────────────────
//       // final response = await http.post(
//       //   Uri.parse('YOUR_API_URL/auth/login'),
//       //   headers: {'Content-Type': 'application/json'},
//       //   body: jsonEncode({
//       //     'email'   : emailController.text.trim(),
//       //     'password': passwordController.text,
//       //   }),
//       // );
//       // final body = jsonDecode(response.body);
//       // final role = body['data']['role'];       // 'kandang' | 'storage' | 'reseller'
//       // final name = body['data']['name'];
//       // final token = body['data']['token'];
//       // await _saveToken(token); // simpan ke SharedPreferences
//       // ────────────────────────────────────────────────────────────────────

//       // Mock response — HAPUS setelah backend siap
//       await Future.delayed(const Duration(seconds: 2));
//       final email = emailController.text.trim();
//       final mockRole = _mockRoleFromEmail(email); // hanya untuk development
//       final mockName = email.split('@')[0].capitalize ?? 'User';

//       isLoading.value = false;

//       Get.snackbar(
//         'Berhasil',
//         'Selamat datang, $mockName!',
//         backgroundColor: Colors.green[100],
//         colorText: Colors.green[900],
//         snackPosition: SnackPosition.TOP,
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 2),
//       );

//       _navigateByRole(
//         role: mockRole,
//         userName: mockName,
//         userRole: mockRole,
//         userId: 'user_001',
//       );

//     } catch (e) {
//       isLoading.value = false;
//       _showError('Login gagal: ${e.toString()}');
//     }
//   }

//   // ─── Role-based Navigation ────────────────────────────────────────────────

//   /// Navigasi ke dashboard yang sesuai berdasarkan role dari backend.
//   /// [role] adalah string yang dikirim backend: 'kandang', 'storage', atau 'reseller'.
//   void _navigateByRole({
//     required String role,
//     required String userName,
//     required String userRole,
//     required String userId,
//   }) {
//     final args = {
//       'userName': userName,
//       'userRole': userRole,
//       'userId'  : userId,
//     };

//     switch (role.toLowerCase()) {
//       case 'kandang':
//         Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG, arguments: args);
//         break;
//       case 'storage':
//         // TODO: Uncomment saat DASHBOARD_STORAGE sudah dibuat
//         // Get.offAllNamed(AppRoutes.DASHBOARD_STORAGE, arguments: args);
//         _showComingSoon('Dashboard Storage');
//         break;
//       case 'reseller':
//         // TODO: Uncomment saat DASHBOARD_RESELLER sudah dibuat
//         // Get.offAllNamed(AppRoutes.DASHBOARD_RESELLER, arguments: args);
//         _showComingSoon('Dashboard Reseller');
//         break;
//       default:
//         _showError('Role tidak dikenali: $role');
//     }
//   }

//   // ─── Helpers ──────────────────────────────────────────────────────────────

//   void handleForgotPassword() => _showComingSoon('Reset Password');
//   void handleRegister()       => _showComingSoon('Registrasi');

//   bool _showError(String message) {
//     Get.snackbar(
//       'Error', message,
//       backgroundColor: Colors.red[100],
//       colorText: Colors.red[900],
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(10),
//     );
//     return false;
//   }

//   void _showComingSoon(String feature) {
//     Get.snackbar(
//       'Info', 'Fitur $feature akan segera tersedia',
//       backgroundColor: Colors.blue[100],
//       colorText: Colors.blue[900],
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(10),
//     );
//   }

//   /// Hanya untuk mock development — HAPUS setelah backend siap.
//   /// Email dengan 'storage' → role storage, 'reseller' → reseller, selain itu → kandang.
//   String _mockRoleFromEmail(String email) {
//     if (email.contains('storage'))  return 'storage';
//     if (email.contains('reseller')) return 'reseller';
//     return 'kandang';
//   }
// }