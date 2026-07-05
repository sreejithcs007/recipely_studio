import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.recipeCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      recipeCount: (json['recipe_count'] ?? json['recipes_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      imageUrl: imageUrl,
      recipeCount: recipeCount,
    );
  }
}
