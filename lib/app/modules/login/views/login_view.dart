import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller diinisialisasi
    final controller = Get.find<LoginController>();

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
                      fontSize: 55,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFED652A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email TextField
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: const TextStyle(color: Color(0xFF666666)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFED652A)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  Obx(() => Container(
                        child: TextField(
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi',
                            labelStyle: const TextStyle(color: Color(0xFF666666)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFED652A)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            floatingLabelStyle: const TextStyle(color: Color(0xFFED652A)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF666666),
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),

                  // Login Button with Loading State
                  Obx(() => Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.login,
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
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),
                  const SizedBox(height: 30),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Baru di Seekly? ',
                        style: TextStyle(
                          color: Color(0xFFED652A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offNamed('/signup'); // Gunakan offNamed untuk ganti halaman
                        },
                        child: const Text(
                          'Buat Akun',
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