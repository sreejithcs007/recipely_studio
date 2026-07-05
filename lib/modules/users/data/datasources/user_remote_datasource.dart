import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final SupabaseClient _supabaseClient;

  UserRemoteDataSource(this._supabaseClient);

  Future<List<UserModel>> getUsers({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    var selectQuery = _supabaseClient
        .from('users')
        .select('*, user_roles!user_roles_user_id_fkey(role)');
    
    if (query != null && query.isNotEmpty) {
      selectQuery = selectQuery.or('name.ilike.%$query%,email.ilike.%$query%');
    }

    final response = await selectQuery
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => UserModel.fromJson(json)).toList();
  }
}
