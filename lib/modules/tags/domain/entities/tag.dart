import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String name;
  final String type; // dietary, cuisine, meal_type, nutrition
  final int recipeCount;

  const Tag({
    required this.id,
    required this.name,
    required this.type,
    this.recipeCount = 0,
  });

  Tag copyWith({
    String? id,
    String? name,
    String? type,
    int? recipeCount,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      recipeCount: recipeCount ?? this.recipeCount,
    );
  }

  @override
  List<Object?> get props => [id, name, type, recipeCount];
}
