import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seekly/app/data/firebase_auth_service.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final verificationCodeController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final selectedRole = ''.obs;

  final _authService = FirebaseAuthService();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register() async {
    isLoading.value = true;
    try {
      final user = await _authService.signUp(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
        verificationCode: verificationCodeController.text.trim(),
      );
      if (user != null) {
        Get.snackbar("Berhasil", "Akun berhasil dibuat!");
        Get.offAllNamed('/login'); // langsung ke home
      }
    } catch (e) {
      Get.snackbar("Gagal", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
