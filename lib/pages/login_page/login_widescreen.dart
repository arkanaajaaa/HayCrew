import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haycrew_app/components/CTextfield.dart';
import 'package:haycrew_app/controllers/LoginController.dart';
import 'package:haycrew_app/components/CButton.dart';

class LoginWidescreen extends GetView<LoginController> {
  const LoginWidescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(40),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Todo List Application",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Login Untuk Melanjutkan",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                const SizedBox(height: 40),
                CTextfield(
                  controller: controller.usernameController,
                  label: 'Username',
                  obscureText: false,
                  labelColor: Colors.black,
                  pass: false,
                  isNumber: false,
                  borderRadius: 24.0,
                  borderWidht: 18,
                  bordercolor: Colors.black,
                ),
                const SizedBox(height: 20),
                CTextfield(
                  controller: controller.passwordController,
                  label: 'Password',
                  obscureText: true,
                  labelColor: Colors.black,
                  pass: false,
                  isNumber: false,
                  borderRadius: 24.0,
                  borderWidht: 18,
                  bordercolor: Colors.black,
                ),
                const SizedBox(height: 32),
                CButton(
                  myText: 'Login',
                  myTextColor: Colors.white,
                  onPressed: controller.login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
