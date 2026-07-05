import '../entities/admin_user.dart';

abstract class AuthRepository {
  Future<AdminUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AdminUser?> getCurrentUser();
}
