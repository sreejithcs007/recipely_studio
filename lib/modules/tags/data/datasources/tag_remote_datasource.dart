import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag_model.dart';

class TagRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TagRemoteDataSource(this._supabaseClient);

  Future<List<TagModel>> getTags() async {
    final response = await _supabaseClient
        .from('tags')
        .select('*, recipe_tags(count)')
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['recipe_tags'];
      int count = 0;
      if (countData is List && countData.isNotEmpty) {
        count = countData[0]['count'] ?? 0;
      } else if (countData is Map) {
        count = countData['count'] ?? 0;
      }
      final updatedJson = Map<String, dynamic>.from(json)..['recipe_count'] = count;
      return TagModel.fromJson(updatedJson);
    }).toList();
  }

  Future<TagModel> createTag(TagModel model) async {
    final response = await _supabaseClient
        .from('tags')
        .insert({
          'name': model.name,
          'type': model.type,
        })
        .select()
        .single();
    return TagModel.fromJson(response);
  }

  Future<TagModel> updateTag(TagModel model) async {
    final response = await _supabaseClient
        .from('tags')
        .update({
          'name': model.name,
          'type': model.type,
        })
        .eq('id', model.id)
        .select()
        .single();
    return TagModel.fromJson(response);
  }

  Future<void> deleteTag(String id) async {
    await _supabaseClient
        .from('tags')
        .delete()
        .eq('id', id);
  }
}
