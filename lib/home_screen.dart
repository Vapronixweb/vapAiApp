import 'package:ai_app/pro_screen.dart';
import 'package:ai_app/prompt_screen.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:ai_app/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'add_screen.dart';
import 'controllers/auth_controller.dart';
import 'generation_history.dart';
import 'models/category_model.dart';
import 'models/prompt_template_model.dart';

class AiVideoHome extends StatefulWidget {
  const AiVideoHome({super.key});

  @override
  State<AiVideoHome> createState() => _AiVideoHomeState();
}

class _AiVideoHomeState extends State<AiVideoHome> {
  final TextEditingController _homePromptController = TextEditingController();

  List<Category> categories = [];
  bool isLoading = true;

  // Navigate to generation screen
  void _navigateToGenerate([String? prefilledText]) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => TextToImageScreen(
          initialPrompt: prefilledText ?? _homePromptController.text,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final token = AuthController.to.accessToken.value;

    // print("User Token: $token");

    _loadCategories();
  }


  Future<void> _loadCategories() async {
    try {
      final result = await CategoryService.fetchCategories();
      setState(() {
        categories = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
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
                SliverToBoxAdapter(child: _buildHeader(context)),

                SliverAppBar(
                  backgroundColor: const Color(0xFF0F0F13),
                  pinned: true, // Keeps input visible at top when scrolling
                  toolbarHeight: 90,
                  flexibleSpace: _buildQuickInputSection(),
                ),

                // SliverToBoxAdapter(child: _buildTrendingTags()),

                // 4. Carousel
                // SliverToBoxAdapter(child: _buildHeroCarousel(context, isTablet)),

                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else
                  ...categories.map((category) {
                    if (category.prompts.isEmpty) {
                      return const SliverToBoxAdapter();
                    }
                    return _buildCategorySection(category, isTablet);
                  }),



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


  Widget _buildCategorySection(Category category, bool isTablet) {
    double cardWidth = isTablet ? 240 : 160;
    double cardHeight = isTablet ? 320 : 220;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CATEGORY TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
            child: Text(
              category.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // PROMPT TEMPLATES
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: category.prompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final prompt = category.prompts[index];
                return _buildPromptCard(category, prompt, cardWidth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(
      Category category,
      PromptTemplate prompt,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PromptScreen(
              category: category,
              promptTemplate: prompt,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(
              prompt.sampleImage ??
                  '$baseUrl/prompts/placeholder.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
          alignment: Alignment.bottomLeft,
          child: Text(
            prompt.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 👤 Greeting
          Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to,",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ).createShader(bounds),
                child: const Text(
                  'Imagine AI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // 🪙 Tokens Badge
          Obx(() {
            final tokens = AuthController.to.user.value?.tokens ?? 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    size: 16,
                    color: Color(0xFFFFD54F),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$tokens',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(width: 10),

          // ⭐ PRO Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProAccessScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 📁 History Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GenerationHistoryScreen(),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: Colors.white70,
                size: 20,
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
                  'Playground',
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