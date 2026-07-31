import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../routes/app_routes.dart';
import '../utils/name_utils.dart';

class LoginController extends GetxController {
  static const String baseUrl = 'http://103.253.212.178';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  final _storage = GetStorage();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

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

  Future<void> handleLogin() async {
    if (!_validateInput()) return;

    isLoading.value = true;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: {'Accept': 'application/json'},
            body: {
              'email': emailController.text.trim(),
              'password': passwordController.text,
            },
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> body;
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        debugPrint('Non-JSON response (${response.statusCode}): ${response.body}');
        _showError('Server tidak merespon dengan benar. Coba lagi nanti.');
        return;
      }

      if (response.statusCode == 200) {
        _storage.write('token', body['access_token']); 
        _storage.write('user', body['data']); 

        final name = nicknameFrom(body['data']['name']);
        final role = body['data']['role'] ?? '';
        final fotoUrl = body['data']['foto_url'] as String?;
        final email = body['data']['email'] as String?;

        Get.snackbar(
          'Berhasil',
          'Selamat datang, $name!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );

        _navigateByRole(
          role: role,
          userName: name,
          userId: body['data']['id'].toString(),
          userPhotoUrl: fotoUrl,
          userEmail: email,
        );
    } else {
      final message = body['message'] ?? 'Login gagal';
      debugPrint('Login error: $message');
      _showError(message);
    }
  } on TimeoutException {
    debugPrint('TIMEOUT');
    _showError('Koneksi timeout. Pastikan server menyala dan IP benar.');
  } catch (e) {
    debugPrint('Exception: $e');
    _showError('Login gagal: ${e.toString()}');
  } finally {
    isLoading.value = false;
  }
  }

  void _navigateByRole({
    required String role,
    required String userName,
    required String userId,
    String? userPhotoUrl,
    String? userEmail,
  }) {
    final args = {
      'userName': userName,
      'userRole': role,
      'userId': userId,
      'userPhotoUrl': userPhotoUrl,
      'userEmail': userEmail,
    };

    switch (role.toLowerCase()) {
      case 'kandang':
        Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG, arguments: args);
        break;
      case 'gudang':
        Get.offAllNamed(AppRoutes.DASHBOARD_STORAGE, arguments: args);
        break;
      case 'reseller':
        _showError('Dashboard Reseller belum tersedia');
        break;
      case 'admin':
        _showError('Dashboard Admin belum tersedia');
        break;
      default:
        _showError('Role tidak dikenali: $role');
    }
  }

  Future<void> handleLogout() async {
    final token = _storage.read('token') ?? '';
    try {
      await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {}
    _storage.erase();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

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

  bool _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
    return false;
  }
}
