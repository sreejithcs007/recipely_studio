import 'package:supabase_flutter/supabase_flutter.dart';

class PermissionService {
  final SupabaseClient _supabaseClient;

  PermissionService(this._supabaseClient);

  /// Fetches the role of a user from the `user_roles` table.
  Future<String?> getUserRole(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return response['role'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Verifies if a user has an admin-like role.
  Future<bool> isAdmin(String userId) async {
    final role = await getUserRole(userId);
    return role == 'admin' || role == 'editor' || role == 'moderator';
  }
}
