import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RecipesRemoteDataSource {
  final SupabaseClient _supabaseClient;

  RecipesRemoteDataSource(this._supabaseClient);

  Future<List<RecipeModel>> getRecipes({
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
    var selectQuery = _supabaseClient
        .from('recipes')
        .select('*, recipe_ingredients(*), recipe_steps(*), recipe_categories(*, categories(*)), recipe_tags(*, tags(*))');

    if (query != null && query.isNotEmpty) {
      selectQuery = selectQuery.ilike('title', '%$query%');
    }

    if (cuisine != null && cuisine.isNotEmpty) {
      selectQuery = selectQuery.eq('cuisine', cuisine);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      selectQuery = selectQuery.eq('difficulty', difficulty);
    }

    if (status != null && status.isNotEmpty) {
      selectQuery = selectQuery.eq('status', status);
    }

    if (isFeatured != null) {
      selectQuery = selectQuery.eq('is_featured', isFeatured);
    }

    if (isTrending != null) {
      selectQuery = selectQuery.eq('is_trending', isTrending);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      // Filter by category via inner join or filter list
      final junctions = await _supabaseClient
          .from('recipe_categories')
          .select('recipe_id')
          .eq('category_id', categoryId);
      
      final recipeIds = (junctions as List).map((j) => j['recipe_id'] as String).toList();
      if (recipeIds.isNotEmpty) {
        selectQuery = selectQuery.inFilter('id', recipeIds);
      } else {
        return [];
      }
    }

    final response = await selectQuery
        .isFilter('deleted_at', null)
        .order(sortBy, ascending: ascending)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => RecipeModel.fromJson(json)).toList();
  }

  Future<RecipeModel> getRecipeById(String id) async {
    final response = await _supabaseClient
        .from('recipes')
        .select('*, recipe_ingredients(*), recipe_steps(*), recipe_categories(*, categories(*)), recipe_tags(*, tags(*))')
        .eq('id', id)
        .single();
    
    return RecipeModel.fromJson(response);
  }

  Future<RecipeModel> saveRecipe(RecipeModel recipe, List<String> categoryIds, List<String> tagIds) async {
    final recipeData = recipe.toJson();
    String? recipeId;

    // Check if updating or inserting
    final isNew = recipe.id.isEmpty || recipe.id.startsWith('temp_');
    
    if (isNew) {
      final response = await _supabaseClient
          .from('recipes')
          .insert(recipeData)
          .select('id')
          .single();
      recipeId = response['id'] as String;
    } else {
      recipeId = recipe.id;
      await _supabaseClient
          .from('recipes')
          .update(recipeData)
          .eq('id', recipeId);

      // Clear existing junction tables/items for clean override
      await _supabaseClient.from('recipe_ingredients').delete().eq('recipe_id', recipeId);
      await _supabaseClient.from('recipe_steps').delete().eq('recipe_id', recipeId);
      await _supabaseClient.from('recipe_categories').delete().eq('recipe_id', recipeId);
      await _supabaseClient.from('recipe_tags').delete().eq('recipe_id', recipeId);
    }

    // Insert ingredients
    if (recipe.ingredients.isNotEmpty) {
      final ingredientsData = recipe.ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final ing = entry.value;
        return {
          'recipe_id': recipeId,
          'name': ing.name,
          'quantity': ing.quantity,
          'quantity_unit': ing.unit,
          'index': index,
          'is_optional': ing.isOptional,
        };
      }).toList();
      await _supabaseClient.from('recipe_ingredients').insert(ingredientsData);
    }

    // Insert steps
    if (recipe.steps.isNotEmpty) {
      final stepsData = recipe.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return {
          'recipe_id': recipeId,
          'step_content': step.content,
          'step_number': index + 1,
        };
      }).toList();
      await _supabaseClient.from('recipe_steps').insert(stepsData);
    }

    // Insert category junctions
    if (categoryIds.isNotEmpty) {
      final catJunctions = categoryIds.map((catId) => {
        'recipe_id': recipeId,
        'category_id': catId,
      }).toList();
      await _supabaseClient.from('recipe_categories').insert(catJunctions);
    }

    // Insert tag junctions
    if (tagIds.isNotEmpty) {
      final tagJunctions = tagIds.map((tagId) => {
        'recipe_id': recipeId,
        'tag_id': tagId,
      }).toList();
      await _supabaseClient.from('recipe_tags').insert(tagJunctions);
    }

    return getRecipeById(recipeId);
  }

  Future<void> deleteRecipe(String id) async {
    // Soft delete setting deleted_at
    await _supabaseClient
        .from('recipes')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
