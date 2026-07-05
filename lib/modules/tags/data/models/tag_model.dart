import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
    required super.type,
    super.recipeCount,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'dietary',
      recipeCount: (json['recipe_count'] ?? json['recipes_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  Tag toEntity() {
    return Tag(
      id: id,
      name: name,
      type: type,
      recipeCount: recipeCount,
    );
  }
}
