import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryRemoteDataSource {
  final SupabaseClient _supabaseClient;

  CategoryRemoteDataSource(this._supabaseClient);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select('*, recipe_categories(count)')
        .isFilter('deleted_at', null)
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['recipe_categories'];
      int count = 0;
      if (countData is List && countData.isNotEmpty) {
        count = countData[0]['count'] ?? 0;
      } else if (countData is Map) {
        count = countData['count'] ?? 0;
      }
      final updatedJson = Map<String, dynamic>.from(json)..['recipe_count'] = count;
      return CategoryModel.fromJson(updatedJson);
    }).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel model) async {
    final response = await _supabaseClient
        .from('categories')
        .insert({
          'name': model.name,
          'image_url': model.imageUrl,
        })
        .select()
        .single();
    return CategoryModel.fromJson(response);
  }

  Future<CategoryModel> updateCategory(CategoryModel model) async {
    final response = await _supabaseClient
        .from('categories')
        .update({
          'name': model.name,
          'image_url': model.imageUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', model.id)
        .select()
        .single();
    return CategoryModel.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _supabaseClient
        .from('categories')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
