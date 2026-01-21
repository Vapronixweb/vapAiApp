import 'package:ai_app/pro_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'image_api.dart'; // Uncomment if you have your API file ready

class TextToImageScreen extends StatefulWidget {
  final String? initialPrompt; // 1. Accepts text passed from Home Screen

  const TextToImageScreen({
    super.key,
    this.initialPrompt
  });

  @override
  State<TextToImageScreen> createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen> {
  final TextEditingController promptController = TextEditingController();

  // State Variables
  bool isLoading = false;
  String? resultUrl;
  File? selectedImage;
  GenerationMode generationMode = GenerationMode.textToImage;
  String? selectedStyle;

  final ImagePicker _imagePicker = ImagePicker();

  // Style Options with icons
  final List<StyleOption> styles = [
    StyleOption("No Style", Icons.palette_outlined),
    StyleOption("Cinematic", Icons.movie_outlined),
    StyleOption("Anime", Icons.arrow_back),
    StyleOption("Photorealistic", Icons.photo_camera_outlined),
    StyleOption("Oil Painting", Icons.brush_outlined),
    StyleOption("Watercolor", Icons.water_drop_outlined),
    StyleOption("Pixel Art", Icons.grid_4x4),
    StyleOption("Cyberpunk", Icons.bolt_outlined),
    StyleOption("3D Render", Icons.view_in_ar_outlined),
  ];

  @override
  void initState() {
    super.initState();
    selectedStyle = styles[0].name;

    // 2. Pre-fill the text if it was passed from Home
    if (widget.initialPrompt != null) {
      promptController.text = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13), // Deep Premium Black
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            _buildHeader(context),

            // --- Scrollable Content ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 3. Mode Selection
                    _buildModeSelection(),

                    // 4. Hero Prompt Section (Expands from Home)
                    _buildPromptSection(size),

                    // 5. Image Upload (Conditional)
                    if (generationMode != GenerationMode.textToImage)
                      _buildImageUploadSection(),

                    // 6. Style Selection
                    _buildStyleSelection(),

                    const SizedBox(height: 20),

                    // 7. Result Section (If generated)
                    if (resultUrl != null)
                      _buildResultSection(),

                    // Bottom padding for scrolling
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- Floating Create Button ---
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ================= UI WIDGETS =================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          const Text(
            "Create Magic",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProAccessScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text("PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(Size size) {
    return Hero(
      tag: 'promptInput',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: 160,
            maxHeight: generationMode == GenerationMode.textToImage
                ? size.height * 0.35
                : 180,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    generationMode == GenerationMode.imageToImage
                        ? "Enhancement Prompt"
                        : "Describe your image",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (generationMode == GenerationMode.textToImage)
                    GestureDetector(
                      onTap: _randomizePrompt,
                      child: const Row(
                        children: [
                          Icon(Icons.shuffle, color: Colors.blueAccent, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Surprise Me",
                            style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: TextField(
                  controller: promptController,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: generationMode == GenerationMode.imageToImage
                        ? "E.g., Make it look like a cyberpunk city..."
                        : "E.g., An astronaut riding a horse on Mars, photorealistic, 4k...",
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _modeChip("Text to Image", GenerationMode.textToImage, Icons.text_fields),
          const SizedBox(width: 10),
          _modeChip("Image to Image", GenerationMode.imageToImage, Icons.image),
          const SizedBox(width: 10),
          _modeChip("Inpainting", GenerationMode.textAndImage, Icons.brush),
        ],
      ),
    );
  }

  Widget _modeChip(String label, GenerationMode mode, IconData icon) {
    bool isSelected = generationMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          generationMode = mode;
          // Clear image if switching to text-only
          if (mode == GenerationMode.textToImage) selectedImage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, style: BorderStyle.solid),
      ),
      child: selectedImage == null
          ? InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: Colors.blueAccent.withOpacity(0.5), size: 40),
            const SizedBox(height: 10),
            const Text("Upload Reference Image", style: TextStyle(color: Colors.white54)),
          ],
        ),
      )
          : Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => setState(() => selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text("Choose Style", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: styles.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final style = styles[index];
              final isSelected = selectedStyle == style.name;
              return GestureDetector(
                onTap: () => setState(() => selectedStyle = style.name),
                child: Column(
                  children: [
                    // Style Icon with Gradient Background
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? const LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : LinearGradient(
                          colors: [
                            const Color(0xFF2A2A35).withOpacity(0.8),
                            const Color(0xFF1E1E24).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : Border.all(color: Colors.white24, width: 1),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          style.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      style.name,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              resultUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconBtn(Icons.file_download_outlined, "Save"),
              _iconBtn(Icons.share_outlined, "Share"),
              _iconBtn(Icons.info_outline, "Info"),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomButton() {
    // Logic to disable button if requirements aren't met
    bool canGenerate = promptController.text.isNotEmpty;
    if (generationMode != GenerationMode.textToImage && selectedImage == null) {
      canGenerate = false;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F13),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ElevatedButton(
        onPressed: canGenerate && !isLoading ? _handleGenerate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGenerate ? const Color(0xFF2D62FF) : Colors.grey[800],
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[900],
          disabledForegroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: canGenerate ? 8 : 0,
          shadowColor: const Color(0xFF2D62FF).withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 10),
            Text("Generate Artwork", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC METHODS =================

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _randomizePrompt() {
    final prompts = [
      "A futuristic city with flying cars, neon lights, cyberpunk style",
      "An oil painting of a cottage in the woods during autumn",
      "A cute robot playing chess with a cat, 3d render",
      "Portrait of a warrior princess, golden armor, dramatic lighting"
    ];
    setState(() {
      promptController.text = prompts[DateTime.now().microsecond % prompts.length];
    });
  }

  Future<void> _handleGenerate() async {
    setState(() => isLoading = true);
    FocusScope.of(context).unfocus(); // Hide keyboard

    try {
      // Simulate API Network Delay
      await Future.delayed(const Duration(seconds: 3));

      // MOCK RESULT: In a real app, call your ImageApi.generateImage here
      setState(() {
        resultUrl = "https://picsum.photos/500/500?random=${DateTime.now().millisecondsSinceEpoch}";
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

// Style Option Model
class StyleOption {
  final String name;
  final IconData icon;

  StyleOption(this.name, this.icon);
}

// Ensure this Enum is available globally or within this file
enum GenerationMode {
  textToImage,
  imageToImage,
  textAndImage,
}