import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    final stats = await _remoteDataSource.getStatistics();
    final growth = await _remoteDataSource.getRecipeGrowth();
    final popular = await _remoteDataSource.getPopularCategories();
    final activity = await _remoteDataSource.getRecentActivity();
    final recentRecipes = await _remoteDataSource.getRecentRecipes();

    return {
      'statistics': stats,
      'recipeGrowth': growth,
      'popularCategories': popular,
      'recentActivity': activity,
      'recentRecipes': recentRecipes,
    };
  }
}
