import 'dart:convert';
import 'dart:io';
import 'package:ai_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'controllers/auth_controller.dart';
import 'models/category_model.dart';
import 'models/prompt_template_model.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PromptScreen extends StatefulWidget {
  final Category category;
  final PromptTemplate promptTemplate;

  const PromptScreen({
    super.key,
    required this.category,
    required this.promptTemplate,
  });

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  String? resultImageUrl;

  Future<void> _pickImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _shareImage() async {
    final file = await _downloadAndSaveImage();
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)]);
    }
  }


  Future<void> _handleGenerate() async {
    setState(() => isLoading = true);

    try {
      final auth = AuthController.to;
      final token = auth.accessToken.value;

      final uri = Uri.parse("$apiUrl/generate/image-to-image");

      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      // PROMPT FROM TEMPLATE
      request.fields['prompt'] = widget.promptTemplate.promptText;

      // IMAGE
      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          resultImageUrl = data['output']['url'];
          isLoading = false;
        });

        AuthController.to.refreshUser();

      } else {
        setState(() => isLoading = false);
        final responseData = jsonDecode(response.body);

        Get.snackbar(
          "Error",
          responseData['message'] ?? "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<File?> _downloadAndSaveImage() async {
    if (resultImageUrl == null) return null;

    try {
      // Request permissions (important for Android)
      await Permission.photos.request();
      await Permission.storage.request();

      // Download image
      final tempDir = await getTemporaryDirectory();
      final filePath =
          "${tempDir.path}/generated_${DateTime.now().millisecondsSinceEpoch}.png";

      await Dio().download("$baseUrl/$resultImageUrl", filePath);

      // Save to gallery using gallery_saver_plus
      final bool? isSaved =
      await GallerySaver.saveImage(filePath, albumName: "Imagine AI");

      if (isSaved == true) {
        Get.snackbar(
          "Saved",
          "Image saved to gallery",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to save image",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return File(filePath);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to download image",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [

        SizedBox(
        height: size.height * 0.52, // slightly more flexible
          width: double.infinity,
          child: Container(
            color: Colors.black, // background for empty space
            child: Stack(
              children: [
                Center(
                  child: resultImageUrl != null
                      ? Image.network(
                    "$baseUrl/${resultImageUrl!}",
                    fit: BoxFit.contain,
                    width: double.infinity,
                  )
                      : selectedImage != null
                      ? Image.file(
                    selectedImage!,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  )
                      : Image.network(
                    widget.promptTemplate.sampleImage ??
                        '$baseUrl/prompts/placeholder.png',
                    fit: BoxFit.fitHeight, // changed from cover
                    width: double.infinity,
                  ),
                ),

                // LOADING OVERLAY
                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ================= DARK GRADIENT =================
            Container(
              height: size.height * 0.52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
        
            // ================= CLOSE BUTTON =================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
        
            // ================= CONTENT =================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== CATEGORY =====
                    Text(
                      widget.category.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
        
                    // ===== TITLE =====
                    Text(
                      widget.promptTemplate.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
        
                    const SizedBox(height: 8),
        
                    // ===== PROMPT DESCRIPTION =====
                    Text(
                      "Generate by uploading your own image",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
        
                    const SizedBox(height: 20),
        
                    // ===== UPLOAD CARD =====
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff141414),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedImage != null
                                ? Colors.blueAccent
                                : Colors.white12,
                          ),
                        ),
                        child: selectedImage == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 42,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 14),
                            Text(
                              "Tap to upload image",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 20),
        
                    // ===== ACTION AREA =====
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: resultImageUrl == null
                          ? GestureDetector(
                        key: const ValueKey("create"),
                        onTap: selectedImage == null || isLoading
                            ? null
                            : _handleGenerate,
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: selectedImage != null && !isLoading
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF2D62FF),
                                Color(0xFF8B5CF6),
                              ],
                            )
                                : null,
                            color: selectedImage == null || isLoading
                                ? Colors.white12
                                : null,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : const Text(
                            "Create",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                          : Row(
                        key: const ValueKey("actions"),
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _shareImage,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C6FF),
                                      Color(0xFF0072FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.share, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Share",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _downloadAndSaveImage,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF11998e),
                                      Color(0xFF38ef7d),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Download",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xff141414),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

