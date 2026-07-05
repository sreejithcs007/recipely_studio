import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final int recipeCount;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.recipeCount = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? recipeCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      recipeCount: recipeCount ?? this.recipeCount,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, recipeCount];
}
