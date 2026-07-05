import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipes_remote_datasource.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipesRemoteDataSource _remoteDataSource;

  RecipeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Recipe>> getRecipes({
    String? query,
    String? categoryId,
    String? cuisine,
    String? difficulty,
    String? status,
    bool? isFeatured,
    bool? isTrending,
    String sortBy = 'created_at',
    bool ascending = false,
    int limit = 20,
    int offset = 0,
  }) async {
    final list = await _remoteDataSource.getRecipes(
      query: query,
      categoryId: categoryId,
      cuisine: cuisine,
      difficulty: difficulty,
      status: status,
      isFeatured: isFeatured,
      isTrending: isTrending,
      sortBy: sortBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    final model = await _remoteDataSource.getRecipeById(id);
    return model.toEntity();
  }

  @override
  Future<Recipe> saveRecipe(Recipe recipe, List<String> categoryIds, List<String> tagIds) async {
    final model = RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      rating: recipe.rating,
      reviewsCount: recipe.reviewsCount,
      prepTime: recipe.prepTime,
      cookTime: recipe.cookTime,
      totalTime: recipe.totalTime,
      calories: recipe.calories,
      servings: recipe.servings,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      totalTimeMinutes: recipe.totalTimeMinutes,
      caloriesInt: recipe.caloriesInt,
      servingsInt: recipe.servingsInt,
      cuisine: recipe.cuisine,
      difficulty: recipe.difficulty,
      spiceLevel: recipe.spiceLevel,
      estimatedCost: recipe.estimatedCost,
      status: recipe.status,
      isFeatured: recipe.isFeatured,
      isTrending: recipe.isTrending,
      isRecommended: recipe.isRecommended,
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
    );
    final result = await _remoteDataSource.saveRecipe(model, categoryIds, tagIds);
    return result.toEntity();
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _remoteDataSource.deleteRecipe(id);
  }
}
