import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  final double size;
  final double left;
  final double top;
  final double opacity;
  final double speed;

  Particle({
    required this.size,
    required this.left,
    required this.top,
    required this.opacity,
    this.speed = 1.0,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 2. Store particles here
  final List<Particle> _particles = [];

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Transform Text into Visuals",
      description: "Generate beautiful, high-quality images from simple text descriptions.",
      icon: Icons.auto_awesome,
      color: const Color(0xFF10B981),
      gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      lottieAsset: "assets/animations/text_to_image.json",
      asset: 'assets/onboarding1.png'
    ),
    OnboardingPage(
      title: "Bring Images to Life",
      description: "Convert static images into dynamic videos with smooth animations.",
      icon: Icons.video_settings,
      color: const Color(0xFF6366F1),
      gradient: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      lottieAsset: "assets/animations/image_to_video.json",
        asset: 'assets/onboarding2.png'
    ),
    OnboardingPage(
      title: "Create & Share",
      description: "Export in HD, customize styles, and share your AI-generated content.",
      icon: Icons.share,
      color: const Color(0xFFEC4899),
      gradient: [const Color(0xFF10B981), const Color(0xFF34D399)],
      lottieAsset: "assets/animations/share_creative.json",
        asset: 'assets/onboarding3.png'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        // This triggers rebuilds, so fixed particle data is crucial
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // 3. Initialize particles once when the screen loads
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      final random = Random();
      for (int i = 0; i < 30; i++) {
        _particles.add(Particle(
          size: random.nextDouble() * 4 + 2,
          left: random.nextDouble() * size.width,
          top: random.nextDouble() * size.height,
          opacity: random.nextDouble() * 0.3 + 0.1,
        ));
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            // Fixed: Background Particles
            _buildParticleBackground(),

            // Main Content
            Column(
              children: [
                // Skip Button
                if (_currentPage < _pages.length - 1)
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      right: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(_pages.length - 1);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text("Skip"),
                      ),
                    ),
                  )
                else
                  SizedBox(height: MediaQuery.of(context).padding.top + 50),

                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      final isActive = index == _currentPage;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 60 : isSmallScreen ? 16 : 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Glow/Image
                            SizedBox(
                              height: isTablet ? 350 : isSmallScreen ? 200 : 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    width: isTablet ? 320 : isSmallScreen ? 180 : 240,
                                    height: isTablet ? 320 : isSmallScreen ? 180 : 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          page.color.withOpacity(isActive ? 0.3 : 0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: isActive
                                          ? [
                                        BoxShadow(
                                          color: page.color.withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ]
                                          : [],
                                    ),
                                  ),
                                  // Placeholder for Lottie (using Icon for now if asset missing)
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Image.asset(page.asset, width: 100,),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isTablet ? 60 : isSmallScreen ? 30 : 40),

                            // Title
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: isActive ? 1 : 0.3,
                              child: Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isTablet ? 40 : isSmallScreen ? 24 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Description
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: index == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: index == _currentPage
                                  ? _pages[_currentPage].color
                                  : Colors.grey[700],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacementNamed(context, "/home");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1 ? "Continue" : "Get Started",
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Fixed _buildParticleBackground method
  Widget _buildParticleBackground() {
    return IgnorePointer(
      child: Stack(
        // Use the pre-generated particle list
        children: _particles.map((particle) {
          final color = _pages[_currentPage].color.withOpacity(particle.opacity);

          return Positioned(
            left: particle.left,
            top: particle.top,
            child: AnimatedContainer(
              duration: const Duration(seconds: 1), // Smooth transition on color change
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String lottieAsset;
  final String asset;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.lottieAsset,
    required this.asset
  });
}