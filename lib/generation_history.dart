import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'generation_preview_screen.dart';
import 'routes/app_routes.dart';

class GenerationHistoryScreen extends StatefulWidget {
  const GenerationHistoryScreen({super.key});

  @override
  State<GenerationHistoryScreen> createState() => _GenerationHistoryScreenState();
}

class _GenerationHistoryScreenState extends State<GenerationHistoryScreen> {
  bool isLoading = true;
  List generations = [];

  @override
  void initState() {
    super.initState();
    fetchGenerations();
  }

  Future<void> fetchGenerations() async {
    try {
      final token = AuthController.to.accessToken.value;

      final response = await http.get(
        Uri.parse("$apiUrl/user/generations"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        setState(() {
          generations = json['data'];
          isLoading = false;
        });
      } else {
        throw response.body;
      }
    } catch (e) {
      isLoading = false;
      Get.snackbar("Error", "$e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("My Creations"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : generations.isEmpty
          ? const Center(
        child: Text("No generations yet",
            style: TextStyle(color: Colors.white54)),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
        itemCount: generations.length,
        itemBuilder: (context, index) {
          final item = generations[index];
          final imageUrl = item['output']?['url'];

          return GestureDetector(
            onTap: item['status'] == 'completed'
                ? () {
              Get.to(() => GenerationPreviewScreen(
                imageUrl: imageUrl,
                prompt: item['prompt'],
              ));
            }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: _buildGenerationThumbnail(item)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item['prompt'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenerationThumbnail(Map item) {
    final status = item['status'];
    final imageUrl = item['output']?['url'];

    // ✅ Completed → Show image
    if (status == 'completed' && imageUrl != null) {
      return Image.network(
        "$baseUrl/$imageUrl",
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(
          icon: Icons.broken_image,
          text: "Image unavailable",
        ),
      );
    }

    // ⏳ Pending
    if (status == 'pending') {
      return _placeholder(
        icon: Icons.hourglass_top_rounded,
        text: "Generating...",
        animated: true,
      );
    }

    // ❌ Failed or anything else
    return _placeholder(
      icon: Icons.close_rounded,
      text: "Not created",
    );
  }

  Widget _placeholder({
    required IconData icon,
    required String text,
    bool animated = false,
  }) {
    return Container(
      color: const Color(0xFF15151B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            animated
                ? const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            )
                : Icon(icon, size: 32, color: Colors.white38),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
