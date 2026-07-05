import '../../domain/entities/user_profile.dart';

class UserModel extends UserProfile {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.avatarUrl,
    required super.chefLevel,
    required super.savedCount,
    required super.cookedCount,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesData = json['user_roles'];
    String userRole = 'User';
    if (rolesData is List && rolesData.isNotEmpty) {
      userRole = rolesData[0]['role'] ?? 'User';
    } else if (rolesData is Map) {
      userRole = rolesData['role'] ?? 'User';
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String? ?? 'user-avatars/default.png',
      chefLevel: json['chef_level'] as String? ?? 'Home Chef',
      savedCount: (json['saved_count'] ?? 0) as int,
      cookedCount: (json['cooked_count'] ?? 0) as int,
      role: userRole,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'chef_level': chefLevel,
      'saved_count': savedCount,
      'cooked_count': cookedCount,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      chefLevel: chefLevel,
      savedCount: savedCount,
      cookedCount: cookedCount,
      role: role,
      createdAt: createdAt,
    );
  }
}
