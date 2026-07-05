import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<List<UserProfile>> getUsers({
    String? query,
    int limit = 50,
    int offset = 0,
  });
}
