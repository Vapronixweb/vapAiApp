import 'prompt_template_model.dart';

class Category {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final List<PromptTemplate> prompts;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.prompts,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
      prompts: (json['prompts'] as List)
          .map((e) => PromptTemplate.fromJson(e))
          .toList(),
    );
  }
}
