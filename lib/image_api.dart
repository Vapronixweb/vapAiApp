import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'add_screen.dart';

class ImageApi {
  static Future<String?> generateImage({
    required String prompt,
    File? imageFile,
    required GenerationMode mode,
    String? style,
  }) async {
    final url = Uri.parse('http://127.0.0.1:8000/generate-image');

    // Create multipart request
    var request = http.MultipartRequest('POST', url);

    // Add fields
    request.fields['prompt'] = prompt;
    request.fields['mode'] = _modeToString(mode);
    if (style != null && style != "No Style") {
      request.fields['style'] = style;
    }

    // Add image if provided
    if (imageFile != null && mode != GenerationMode.textToImage) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['image_url'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate image');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static String _modeToString(GenerationMode mode) {
    switch (mode) {
      case GenerationMode.textToImage:
        return 'text_to_image';
      case GenerationMode.imageToImage:
        return 'image_to_image';
      case GenerationMode.textAndImage:
        return 'text_and_image';
    }
  }
}