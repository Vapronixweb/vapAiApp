import 'package:ai_app/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'add_screen.dart'; // Import your updated add_screen

class AiVideoHome extends StatefulWidget {
  const AiVideoHome({super.key});

  @override
  State<AiVideoHome> createState() => _AiVideoHomeState();
}

class _AiVideoHomeState extends State<AiVideoHome> {
  final TextEditingController _homePromptController = TextEditingController();

  // Navigate to generation screen
  void _navigateToGenerate([String? prefilledText]) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => TextToImageScreen(
          initialPrompt: prefilledText ?? _homePromptController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Custom Header with Gradient Text
                SliverToBoxAdapter(child: _buildHeader()),

                // 2. THE MAGIC INPUT FIELD (Hero)
                SliverAppBar(
                  backgroundColor: const Color(0xFF0F0F13),
                  pinned: true, // Keeps input visible at top when scrolling
                  toolbarHeight: 90,
                  flexibleSpace: _buildQuickInputSection(),
                ),

                // 3. Trending Tags (Unique Addon)
                SliverToBoxAdapter(child: _buildTrendingTags()),

                // 4. Carousel
                SliverToBoxAdapter(child: _buildHeroCarousel(context, isTablet)),

                // 5. Sections
                _buildResponsiveCarouselSection(
                  context,
                  title: 'Trending Now',
                  isTablet: isTablet,
                  items: const [
                    _CardItem('CYBERPUNK CITY', 'assets/hero.jpg'),
                    _CardItem('ANIME FIGHT', 'assets/news.jpeg'),
                  ],
                ),

                _buildResponsiveCarouselSection(
                  context,
                  title: 'Community Best',
                  isTablet: isTablet,
                  items: const [
                    _CardItem('OIL PAINTING', 'assets/baby.jpeg'),
                    _CardItem('REALISTIC', 'assets/news2.webp'),
                    _CardItem('REALISTIC', 'assets/news2.webp'),
                  ],
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // Fixed Floating Action Button at Bottom
            _buildCreateButton(context, isTablet),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGETS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome,",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ).createShader(bounds),
                child: const Text(
                  'Hrithik Dwivedi',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProAccessScreen()));
            },
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInputSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Hero(
          tag: 'promptInput', // Matches the tag in TextToImageScreen
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 60, // Fixed height for AppBar
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.auto_awesome, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _homePromptController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) => _navigateToGenerate(),
                      decoration: const InputDecoration(
                        hintText: "What do you want to create?",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToGenerate(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D62FF), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTags() {
    final tags = ["Astronaut in jungle", "Cyberpunk cat", "Underwater city", "Neon Portrait"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _navigateToGenerate(tags[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                tags[index],
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- EXISTING COMPONENTS (Simplified for brevity) ---

  Widget _buildHeroCarousel(BuildContext context, bool isTablet) {
    // Reduced top padding since we have the input field now
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: CarouselSlider(
        options: CarouselOptions(
          height: isTablet ? 350 : 200,
          viewportFraction: 0.85,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        items: [1, 2, 3].map((i) => _buildHeroItem()).toList(),
      ),
    );
  }

  Widget _buildHeroItem() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900], // Fallback color
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage('assets/hero.jpg'), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [Colors.black, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)
              ),
              child: const Text("Featured Creation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResponsiveCarouselSection(
      BuildContext context, {
        required String title,
        required List<_CardItem> items,
        required bool isTablet,
      }) {
    // Dynamic sizes based on screen
    double cardWidth = isTablet ? 240 : 160;
    double cardHeight = isTablet ? 320 : 220;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text('See All', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildSectionCard(items[index], cardWidth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(_CardItem item, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(image: AssetImage(item.image), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }


  Widget _buildCreateButton(BuildContext context, bool isTablet) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: isTablet ? 400 : screenWidth * 0.85,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TextToImageScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Create a Video',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardItem {
  final String title;
  final String image;
  const _CardItem(this.title, this.image);
}