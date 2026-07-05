import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.rating,
    required super.reviewsCount,
    required super.prepTime,
    required super.cookTime,
    required super.totalTime,
    required super.calories,
    required super.servings,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.totalTimeMinutes,
    required super.caloriesInt,
    required super.servingsInt,
    super.cuisine,
    required super.difficulty,
    required super.spiceLevel,
    required super.estimatedCost,
    required super.status,
    required super.isFeatured,
    required super.isTrending,
    required super.isRecommended,
    required super.imageUrl,
    required super.createdAt,
    super.ingredients,
    super.steps,
    super.categories,
    super.tags,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    var ingredients = <Ingredient>[];
    if (json['recipe_ingredients'] != null) {
      final list = json['recipe_ingredients'] as List;
      ingredients = list.map((item) {
        return Ingredient(
          name: item['name'] as String? ?? '',
          quantity: item['quantity'] as String? ?? item['display_quantity'] as String? ?? '',
          unit: item['quantity_unit'] as String?,
          isOptional: item['is_optional'] as bool? ?? false,
        );
      }).toList();
    }

    var steps = <StepItem>[];
    if (json['recipe_steps'] != null) {
      final list = json['recipe_steps'] as List;
      steps = list.map((item) {
        return StepItem(
          content: item['step_content'] as String? ?? '',
          stepNumber: (item['step_number'] ?? 1) as int,
        );
      }).toList();
    }

    var categories = <String>[];
    if (json['recipe_categories'] != null) {
      final list = json['recipe_categories'] as List;
      categories = list.map((item) {
        final cat = item['categories'];
        if (cat is Map) {
          return cat['name'] as String? ?? item['category_id'] as String;
        }
        return item['category_id'] as String;
      }).toList();
    }

    var tags = <String>[];
    if (json['recipe_tags'] != null) {
      final list = json['recipe_tags'] as List;
      tags = list.map((item) {
        final tg = item['tags'];
        if (tg is Map) {
          return tg['name'] as String? ?? item['tag_id'] as String;
        }
        return item['tag_id'] as String;
      }).toList();
    }

    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] ?? 0) as int,
      prepTime: json['prep_time'] as String? ?? '10 min',
      cookTime: json['cook_time'] as String? ?? '20 min',
      totalTime: json['total_time'] as String? ?? '30 min',
      calories: json['calories'] as String? ?? '0 kcal',
      servings: json['servings'] as String? ?? '4 servings',
      prepTimeMinutes: (json['prep_time_minutes'] ?? 10) as int,
      cookTimeMinutes: (json['cook_time_minutes'] ?? 20) as int,
      totalTimeMinutes: (json['total_time_minutes'] ?? 30) as int,
      caloriesInt: (json['calories_int'] ?? 0) as int,
      servingsInt: (json['servings_int'] ?? 4) as int,
      cuisine: json['cuisine'] as String?,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      spiceLevel: (json['spice_level'] ?? 0) as int,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'published',
      isFeatured: json['is_featured'] as bool? ?? false,
      isTrending: json['is_trending'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? false,
      imageUrl: json['thumbnail_image_url'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      ingredients: ingredients,
      steps: steps,
      categories: categories,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'total_time': totalTime,
      'calories': calories,
      'servings': servings,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'total_time_minutes': totalTimeMinutes,
      'calories_int': caloriesInt,
      'servings_int': servingsInt,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'spice_level': spiceLevel,
      'estimated_cost': estimatedCost,
      'status': status,
      'is_featured': isFeatured,
      'is_trending': isTrending,
      'is_recommended': isRecommended,
      'thumbnail_image_url': imageUrl,
    };
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      title: title,
      description: description,
      rating: rating,
      reviewsCount: reviewsCount,
      prepTime: prepTime,
      cookTime: cookTime,
      totalTime: totalTime,
      calories: calories,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      totalTimeMinutes: totalTimeMinutes,
      caloriesInt: caloriesInt,
      servingsInt: servingsInt,
      cuisine: cuisine,
      difficulty: difficulty,
      spiceLevel: spiceLevel,
      estimatedCost: estimatedCost,
      status: status,
      isFeatured: isFeatured,
      isTrending: isTrending,
      isRecommended: isRecommended,
      imageUrl: imageUrl,
      createdAt: createdAt,
      ingredients: ingredients,
      steps: steps,
      categories: categories,
      tags: tags,
    );
  }
}
