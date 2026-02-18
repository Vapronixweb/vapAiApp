import 'package:ai_app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class GenerationPreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String prompt;

  const GenerationPreviewScreen({
    super.key,
    required this.imageUrl,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.network(
                "$baseUrl/$imageUrl",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
