import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Controller untuk Login Page
/// Handles semua state dan logic untuk login
class LoginController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable state
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    // Dispose controllers saat controller di-destroy
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validate input
  bool validateInput() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return false;
    }

    return true;
  }

  /// Handle login
  Future<void> handleLogin() async {
    // Validate
    if (!validateInput()) return;

    try {
      isLoading.value = true;

      // Simulate API call (ganti dengan actual API call)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('YOUR_API_URL/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'email': emailController.text.trim(),
      //     'password': passwordController.text,
      //   }),
      // );

      // Mock success
      final email = emailController.text.trim();
      final mockUserData = {
        'userId': 'user_001',
        'name': email.split('@')[0].capitalize ?? 'User',
        'role': 'Karyawan Kandang',
      };

      isLoading.value = false;

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Login berhasil! Selamat datang ${mockUserData['name']}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      );

      // Navigate to HomePage (uncomment setelah integrate)
      // Get.offAll(() => HomePageMultiDashboard(
      //   userId: mockUserData['userId']!,
      //   userName: mockUserData['name']!,
      //   userRole: mockUserData['role']!,
      // ));

      // For now, just log
      print('Login Success: $mockUserData');
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        'Error',
        'Login gagal: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  /// Handle forgot password
  void handleForgotPassword() {
    Get.snackbar(
      'Info',
      'Fitur reset password akan segera tersedia',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  /// Handle register
  void handleRegister() {
    Get.snackbar(
      'Info',
      'Fitur registrasi akan segera tersedia',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }
}