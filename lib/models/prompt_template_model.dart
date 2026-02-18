class PromptTemplate {
  final int id;
  final int categoryId;
  final String title;
  final String promptText;
  final String inputType;
  final String? sampleImage;

  PromptTemplate({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.promptText,
    required this.inputType,
    this.sampleImage,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      id: json['id'],
      categoryId: json['category_id'],
      title: json['title'],
      promptText: json['prompt_text'],
      inputType: json['input_type'],
      sampleImage: json['sample_image'],
    );
  }
}
