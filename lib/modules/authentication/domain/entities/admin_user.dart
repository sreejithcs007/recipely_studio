import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String avatarUrl;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, name, role, avatarUrl];
}
