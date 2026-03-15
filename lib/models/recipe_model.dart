class Recipe {
  int? id;
  String title;
  String? shortDescription;
  String category;
  String? ingredients;
  String? instructions;
  String? coverImage;
  int? prepTime;
  int? cookTime;
  int? servings;
  String? difficulty;
  String? tags;
  int isFavorite;
  double? ratingScore;
  int reviewCount;
  int? calories;
  String? protein;
  String? fat;
  String? carbs;
  int isDailySpecial;
  int viewCount;
  String createdAt;
  String? updatedAt;

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
    this.isFavorite = 0,
    this.ratingScore,
    this.reviewCount = 0,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.isDailySpecial = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Veritabanına (SQLite) yazmak için JSON'a çevirme metodu
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
      'is_favorite': isFavorite,
      'rating_score': ratingScore,
      'review_count': reviewCount,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'is_daily_special': isDailySpecial,
      'view_count': viewCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Veritabanından (SQLite) okunan Map verisini nesneye (Object) çevirme metodu
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      shortDescription: map['short_description'],
      category: map['category'],
      ingredients: map['ingredients'],
      instructions: map['instructions'],
      coverImage: map['cover_image'],
      prepTime: map['prep_time'],
      cookTime: map['cook_time'],
      servings: map['servings'],
      difficulty: map['difficulty'],
      tags: map['tags'],
      isFavorite: map['is_favorite'] ?? 0,
      ratingScore: map['rating_score'],
      reviewCount: map['review_count'] ?? 0,
      calories: map['calories'],
      protein: map['protein'],
      fat: map['fat'],
      carbs: map['carbs'],
      isDailySpecial: map['is_daily_special'] ?? 0,
      viewCount: map['view_count'] ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // --- BURASI EKLENDİ ---
  // Nesnenin bir kopyasını oluşturup istenen alanları güncelleyen metod
  Recipe copyWith({
    int? id,
    String? title,
    String? shortDescription,
    String? category,
    String? ingredients,
    String? instructions,
    String? coverImage,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    String? tags,
    int? isFavorite,
    double? ratingScore,
    int? reviewCount,
    int? calories,
    String? protein,
    String? fat,
    String? carbs,
    int? isDailySpecial,
    int? viewCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      coverImage: coverImage ?? this.coverImage,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      ratingScore: ratingScore ?? this.ratingScore,
      reviewCount: reviewCount ?? this.reviewCount,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      isDailySpecial: isDailySpecial ?? this.isDailySpecial,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}