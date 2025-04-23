import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> 
{
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 5), () {
      Get.offNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Seekly',
          style: GoogleFonts.montserrat(
          fontSize: 70,
          fontWeight: FontWeight.w800,
          color: Color(0xFFED652A)
          ),
        ),
      ),
    );
  }
}
