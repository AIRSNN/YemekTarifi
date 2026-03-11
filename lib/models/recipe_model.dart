class Recipe {
  final int? id;
  final String title;
  final String category; // YENİ EKLENEN KATEGORİ SÜTUNU
  final String ingredients;
  final String instructions;
  final String? imageName;
  final String createdAt;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.imageName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'image_name': imageName,
      'created_at': createdAt,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      imageName: map['image_name'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}