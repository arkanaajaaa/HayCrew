import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:haycrew_app/controllers/SplashscreenController.dart';

class Splashscreenpage extends StatelessWidget {
  Splashscreenpage({super.key});

  final controller = Get.find<Splashscreencontroller>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 20),

            Text(
              "Todo App",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
