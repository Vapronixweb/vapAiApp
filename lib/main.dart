import 'dart:io';

import 'package:ai_app/home_screen.dart';
import 'package:ai_app/onboarding_screen.dart';
import 'package:ai_app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'controllers/auth_controller.dart';
import 'splash_screen.dart';

late Mixpanel mixpanel;

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  if (Platform.isAndroid) {

    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    final notificationService = NotificationService();
    notificationService.requestNotificationPermission();
  }
  Get.put(AuthController());

  mixpanel = await Mixpanel.init(
    "10d1d520a1393ce42700580e904c8e5e",
    trackAutomaticEvents: true,
  );

  runApp(const AiApp());
}



class AiApp extends StatelessWidget {
  const AiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Imagine AI",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffFDF7F2),
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xff3A3A3A),
        useMaterial3: true,
      ),

      /// 👉 Dark Mode Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        primaryColor: Colors.white,
        useMaterial3: true,
      ),

      /// 👉 Adaptive theme
      themeMode: ThemeMode.dark,

      /// 👉 Route Configuration
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
      },

      /// 👉 Smooth page transition globally
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return _routeBuilder(settings);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));
            return FadeTransition(opacity: animation.drive(tween), child: child);
          },
        );
      },
    );
  }

  Widget _routeBuilder(RouteSettings settings) {
    switch (settings.name) {
      case "/onboarding":
        return OnboardingScreen();
      case "/home":
        return AiVideoHome();
      default:
        return const SplashScreen();
    }
  }
}
