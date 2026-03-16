import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/controllers/loginController.dart';
import '../components/CButton.dart';
import '../components/CTextfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  
                  const SizedBox(height: 60),

                  /// LOGO
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 230,
                  ),

                  const SizedBox(height: 20),

                  /// TEXT SELAMAT DATANG
                  const Text(
                    'Selamat Datang di',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1F5A3C),
                    ),
                  ),
                  
                  const Text(
                    'HayCrew',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F5A3C),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// EMAIL
                  CTextField(
                    controller: controller.emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    fillColor: const Color(0xFFEDEBD9),
                    hintColor: const Color(0xFF1F5A3C),
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        hintText: "Kata sandi",
                        hintStyle: const TextStyle(
                          color: Color(0xFF1F5A3C),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEDEBD9),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF1F5A3C),
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTON LOGIN
                  Obx(
                    () => CButton(
                      text: controller.isLoading.value
                          ? "Loading..."
                          : "Masuk",
                      onPressed: controller.isLoading.value
                          ? () {}
                          : controller.handleLogin,
                      color: const Color(0xFF2F6B4F),
                      height: 56,
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}