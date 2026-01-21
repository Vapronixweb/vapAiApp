import 'dart:io';
import 'package:http/http.dart' as http;

class VideoApi {
  static Future<String?> imageToVideo(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/image-to-video'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', image.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return body; // parse JSON
    }
    return null;
  }
}
