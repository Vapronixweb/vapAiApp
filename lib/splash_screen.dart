import 'package:ai_app/utils/helper.dart' as DeviceService;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'dart:async';
import 'dart:ui';

import 'controllers/auth_controller.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _shimmerController;

  // Background animation
  late AnimationController _bgController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // 1. Icon Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Text Shimmer Animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 3. Background Mesh Gradient Animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_bgController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_bgController);

  }


  Future<void> _bootstrap() async {

    mixpanel.track(
      "Splash Screen Viewed",
      properties: {
        "timestamp": DateTime.now().toIso8601String(),
      },
    );

    final auth = AuthController.to;

    final deviceToken = await DeviceService.getDeviceToken();

    await auth.deviceLogin(deviceToken);

    Future.delayed(const Duration(seconds: 4), () {
      if (auth.isLoggedIn.value) {

        mixpanel.track(
          "User Auto Logged In",
          properties: {
            "source": "device_login",
          },
        );

        Get.offAllNamed("/home");
      } else {

        mixpanel.track(
          "Onboarding Started",
          properties: {
            "source": "fresh_user",
            "device_login": false,
          },
        );

        Get.offAllNamed("/onboarding");
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // A. Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: const [
                      Color(0xFF0F172A), // Slate 900
                      Color(0xFF312E81), // Indigo 900
                      Color(0xFF4C1D95), // Violet 900
                      Colors.black,
                    ],
                  ),
                ),
              );
            },
          ),

          // B. Ambient Glow (Orbs)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.2),
                boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          // C. Center Content with Glassmorphism
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Pulsing Logo Icon
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset('assets/app_icon_white.png', width: 60,),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 2. Shimmering Text Title
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: const [
                                  Colors.white,
                                  Colors.purpleAccent,
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment(-1.0 + (_shimmerController.value * 3), 0.0),
                                end: Alignment(1.0 + (_shimmerController.value * 3), 0.0),
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              "IMAGINE AI",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                color: Colors.white, // Color is overridden by ShaderMask
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Transform your images into creatives",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // D. Footer Loading Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}