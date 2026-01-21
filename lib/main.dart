import 'package:ai_app/home_screen.dart';
import 'package:ai_app/onboarding_screen.dart';
import 'package:ai_app/prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const AiApp());
}

class AiApp extends StatelessWidget {
  const AiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "ThinQon Echo",
      debugShowCheckedModeBanner: false,

      /// 👉 Global Theme
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
      case "/prompt":
        return PromptScreen();
      case "/home":
        return AiVideoHome();
      default:
        return const SplashScreen();
    }
  }
}
