import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient _supabaseClient;

  DashboardRemoteDataSource(this._supabaseClient);

  Future<Map<String, dynamic>> getStatistics() async {
    // Perform efficient counts using count: CountOption.exact and head: true
    final totalRecipesRes = await _supabaseClient
        .from('recipes')
        .select('id')
        .isFilter('deleted_at', null);

    final featuredRecipesRes = await _supabaseClient
        .from('recipes')
        .select('id')
        .eq('is_featured', true)
        .isFilter('deleted_at', null);

    final trendingRecipesRes = await _supabaseClient
        .from('recipes')
        .select('id')
        .eq('is_trending', true)
        .isFilter('deleted_at', null);

    final draftRecipesRes = await _supabaseClient
        .from('recipes')
        .select('id')
        .eq('status', 'draft')
        .isFilter('deleted_at', null);

    final categoriesRes = await _supabaseClient
        .from('categories')
        .select('id')
        .isFilter('deleted_at', null);

    final usersRes = await _supabaseClient
        .from('users')
        .select('id')
        .isFilter('deleted_at', null);

    final favoritesRes = await _supabaseClient
        .from('favorites')
        .select('recipe_id');

    return {
      'totalRecipes': totalRecipesRes.length,
      'featuredRecipes': featuredRecipesRes.length,
      'trendingRecipes': trendingRecipesRes.length,
      'draftRecipes': draftRecipesRes.length,
      'totalCategories': categoriesRes.length,
      'totalUsers': usersRes.length,
      'totalFavorites': favoritesRes.length,
    };
  }

  Future<List<Map<String, dynamic>>> getRecipeGrowth() async {
    // Fetch creation timestamps for recipes to plot month-over-month growth
    final response = await _supabaseClient
        .from('recipes')
        .select('created_at')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    return (response as List).map((json) => json as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getPopularCategories() async {
    // Query category names and their referenced recipe counts
    final response = await _supabaseClient
        .from('categories')
        .select('name, recipe_categories(count)')
        .isFilter('deleted_at', null)
        .limit(5);

    return (response as List).map((json) {
      final list = json['recipe_categories'] as List?;
      int count = 0;
      if (list != null && list.isNotEmpty) {
        count = list[0]['count'] ?? 0;
      }
      return {
        'name': json['name'] as String,
        'count': count,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    // Query admin logs joined with admin profile details if any
    final response = await _supabaseClient
        .from('admin_logs')
        .select('*, admin:admin_id(name)')
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List).map((json) => json as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentRecipes() async {
    // Fetch top 5 recently created recipes
    final response = await _supabaseClient
        .from('recipes')
        .select('id, title, status, created_at, image_url, cuisine, difficulty')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List).map((json) => json as Map<String, dynamic>).toList();
  }
}
