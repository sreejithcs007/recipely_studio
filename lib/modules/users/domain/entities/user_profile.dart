import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final String avatarUrl;
  final String chefLevel;
  final int savedCount;
  final int cookedCount;
  final String role;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.chefLevel,
    required this.savedCount,
    required this.cookedCount,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        chefLevel,
        savedCount,
        cookedCount,
        role,
        createdAt,
      ];
}
