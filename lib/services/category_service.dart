import 'dart:convert';
import 'package:ai_app/routes/app_routes.dart';
import '../models/category_model.dart';
import 'package:http/http.dart' as http;

class CategoryService {

  static Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('$apiUrl/categories'));

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return (body['data'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load categories');
  }
}
