import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seekly/app/data/firebase_auth_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  final _authService = FirebaseAuthService();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {
        Get.snackbar("Berhasil", "Login berhasil!");
        Get.offAllNamed('/navbar'); // arahkan ke halaman home
      }
    } catch (e) {
      Get.snackbar("Gagal", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
