import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Seekly',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFED652A),
                    ),
                  ),
                  const Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Nama TextField
                  TextField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      labelStyle: const TextStyle(color: Color(0xFF666666)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFED652A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email TextField
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Color(0xFF666666)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFED652A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          labelStyle: const TextStyle(color: Color(0xFF666666)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFED652A)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF666666),
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedRole.value.isEmpty ? null : controller.selectedRole.value,
                        hint: const Text('Pilih Role', style: TextStyle(color: Color(0xFF666666))),
                        items: ['siswa', 'guru'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role.capitalizeFirst!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.selectedRole.value = value ?? 'siswa';
                        },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: const TextStyle(color: Color(0xFF666666)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFED652A)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Kode Verifikasi (hanya muncul jika pilih guru)
                  Obx(() => controller.selectedRole.value == 'guru'
                      ? TextField(
                          controller: controller.verificationCodeController,
                          decoration: InputDecoration(
                            labelText: 'Kode Verifikasi Guru',
                            labelStyle: const TextStyle(color: Color(0xFF666666)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFED652A)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                          ),
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 30),

                  // Register Button
                  Obx(() => Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED652A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Buat Akun Baru',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),
                  const SizedBox(height: 30),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah Mempunyai Akun? ',
                        style: TextStyle(
                          color: Color(0xFFED652A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offNamed('/login');
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Color(0xF22760DC),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}