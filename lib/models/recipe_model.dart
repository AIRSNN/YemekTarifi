class Recipe {
  final int? id;
  final String title;
  final String? shortDescription;
  final String category;
  final String? ingredients;
  final String? instructions;
  final String? coverImage;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final String? difficulty;
  final String? tags;
  final bool isFavorite;
  final double? ratingScore;
  final int reviewCount;
  final int? calories;
  final String? protein;
  final String? fat;
  final String? carbs;
  final bool isDailySpecial;
  final int viewCount;
  final String createdAt;
  final String? updatedAt;

  Recipe({
    this.id,
    required this.title,
    this.shortDescription,
    required this.category,
    this.ingredients,
    this.instructions,
    this.coverImage,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.difficulty,
    this.tags,
    this.isFavorite = false,
    this.ratingScore,
    this.reviewCount = 0,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.isDailySpecial = false,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      shortDescription: map['short_description'] as String?,
      category: map['category'] as String,
      ingredients: map['ingredients'] as String?,
      instructions: map['instructions'] as String?,
      coverImage: map['cover_image'] as String?,
      prepTime: map['prep_time'] as int?,
      cookTime: map['cook_time'] as int?,
      servings: map['servings'] as int?,
      difficulty: map['difficulty'] as String?,
      tags: map['tags'] as String?,
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      ratingScore: map['rating_score'] as double?,
      reviewCount: map['review_count'] as int? ?? 0,
      calories: map['calories'] as int?,
      protein: map['protein'] as String?,
      fat: map['fat'] as String?,
      carbs: map['carbs'] as String?,
      isDailySpecial: (map['is_daily_special'] ?? 0) == 1,
      viewCount: map['view_count'] as int? ?? 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'short_description': shortDescription,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'cover_image': coverImage,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'tags': tags,
      'is_favorite': isFavorite ? 1 : 0,
      'rating_score': ratingScore,
      'review_count': reviewCount,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'is_daily_special': isDailySpecial ? 1 : 0,
      'view_count': viewCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
