import '../entities/recipe.dart';

abstract class RecipeRepository {
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
  });

  Future<Recipe> getRecipeById(String id);

  Future<Recipe> saveRecipe(Recipe recipe, List<String> categoryIds, List<String> tagIds);

  Future<void> deleteRecipe(String id);
}
