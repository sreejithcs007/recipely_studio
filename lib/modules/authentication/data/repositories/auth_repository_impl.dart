import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminUser> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );

    if (session == null || session.user == null) {
      throw Exception('Failed to sign in: Session is invalid.');
    }

    final userId = session.user!.id;
    var role = await _remoteDataSource.getUserRole(userId);

    // Owner / developer auto-bypass fallback to allow initial login setup
    if (role == null && (session.user!.email == 'sreejithcs365@gmail.com')) {
      role = 'admin';
      try {
        await _remoteDataSource.assignUserRole(userId, 'admin');
      } catch (e) {
        // Log it but continue so they can still access
        print('Error inserting admin user role: $e');
      }
    }

    if (role == null || (role != 'admin' && role != 'editor' && role != 'moderator')) {
      await _remoteDataSource.signOut();
      throw Exception('Access Denied: You do not have permission to access the admin panel.');
    }

    final profile = await _remoteDataSource.getUserProfile(userId);
    final String name = profile?['name'] as String? ?? profile?['username'] as String? ?? 'Admin User';
    final String avatarUrl = profile?['avatar_url'] as String? ?? 'user-avatars/default.png';

    return AdminUser(
      id: userId,
      email: session.user!.email ?? email,
      name: name,
      role: role,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<AdminUser?> getCurrentUser() async {
    final session = _remoteDataSource.getActiveSession();
    if (session == null || session.user == null) {
      return null;
    }

    final userId = session.user!.id;
    var role = await _remoteDataSource.getUserRole(userId);

    // Owner / developer auto-bypass fallback to allow initial login setup
    if (role == null && (session.user!.email == 'sreejithcs365@gmail.com')) {
      role = 'admin';
      try {
        await _remoteDataSource.assignUserRole(userId, 'admin');
      } catch (e) {
        // Log it but continue so they can still access
        print('Error inserting admin user role: $e');
      }
    }

    if (role == null || (role != 'admin' && role != 'editor' && role != 'moderator')) {
      return null;
    }

    final profile = await _remoteDataSource.getUserProfile(userId);
    final String name = profile?['name'] as String? ?? profile?['username'] as String? ?? 'Admin User';
    final String avatarUrl = profile?['avatar_url'] as String? ?? 'user-avatars/default.png';

    return AdminUser(
      id: userId,
      email: session.user!.email ?? '',
      name: name,
      role: role,
      avatarUrl: avatarUrl,
    );
  }
}
