import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<UserProfile>> getUsers({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final models = await _remoteDataSource.getUsers(
      query: query,
      limit: limit,
      offset: offset,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
