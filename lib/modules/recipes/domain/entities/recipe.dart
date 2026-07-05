import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String quantity;
  final String? unit;
  final bool isOptional;

  const Ingredient({
    required this.name,
    required this.quantity,
    this.unit,
    this.isOptional = false,
  });

  @override
  List<Object?> get props => [name, quantity, unit, isOptional];
}

class StepItem extends Equatable {
  final String content;
  final int stepNumber;

  const StepItem({
    required this.content,
    required this.stepNumber,
  });

  @override
  List<Object?> get props => [content, stepNumber];
}

class Recipe extends Equatable {
  final String id;
  final String title;
  final String description;
  final double rating;
  final int reviewsCount;
  final String prepTime;
  final String cookTime;
  final String totalTime;
  final String calories;
  final String servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int totalTimeMinutes;
  final int caloriesInt;
  final int servingsInt;
  final String? cuisine;
  final String difficulty;
  final int spiceLevel;
  final double estimatedCost;
  final String status; // draft, published
  final bool isFeatured;
  final bool isTrending;
  final bool isRecommended;
  final String imageUrl;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final List<StepItem> steps;
  final List<String> categories; // category names or IDs
  final List<String> tags; // tag names or IDs

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewsCount,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.calories,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.totalTimeMinutes,
    required this.caloriesInt,
    required this.servingsInt,
    this.cuisine,
    required this.difficulty,
    required this.spiceLevel,
    required this.estimatedCost,
    required this.status,
    required this.isFeatured,
    required this.isTrending,
    required this.isRecommended,
    required this.imageUrl,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
    this.categories = const [],
    this.tags = const [],
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    double? rating,
    int? reviewsCount,
    String? prepTime,
    String? cookTime,
    String? totalTime,
    String? calories,
    String? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? totalTimeMinutes,
    int? caloriesInt,
    int? servingsInt,
    String? cuisine,
    String? difficulty,
    int? spiceLevel,
    double? estimatedCost,
    String? status,
    bool? isFeatured,
    bool? isTrending,
    bool? isRecommended,
    String? imageUrl,
    DateTime? createdAt,
    List<Ingredient>? ingredients,
    List<StepItem>? steps,
    List<String>? categories,
    List<String>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      totalTime: totalTime ?? this.totalTime,
      calories: calories ?? this.calories,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      caloriesInt: caloriesInt ?? this.caloriesInt,
      servingsInt: servingsInt ?? this.servingsInt,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isRecommended: isRecommended ?? this.isRecommended,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        rating,
        reviewsCount,
        prepTime,
        cookTime,
        totalTime,
        calories,
        servings,
        prepTimeMinutes,
        cookTimeMinutes,
        totalTimeMinutes,
        caloriesInt,
        servingsInt,
        cuisine,
        difficulty,
        spiceLevel,
        estimatedCost,
        status,
        isFeatured,
        isTrending,
        isRecommended,
        imageUrl,
        createdAt,
        ingredients,
        steps,
        categories,
        tags,
      ];
}
