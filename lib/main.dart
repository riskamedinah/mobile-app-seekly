import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;
import './timeago_id.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  timeago.setLocaleMessages('id', CustomIdMessages());
  runApp(
    
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Seekly",
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      initialRoute: Routes.SPLASH_SCREEN,
      getPages: AppPages.routes,
    ),
  );
}
