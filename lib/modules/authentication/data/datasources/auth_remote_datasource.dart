import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSource(this._supabaseClient);

  Future<Session?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session;
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Session? getActiveSession() {
    return _supabaseClient.auth.currentSession;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await _supabaseClient
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<String?> getUserRole(String userId) async {
    final roleResp = await _supabaseClient
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();

    if (roleResp != null) {
      return roleResp['role'] as String?;
    }
    return null;
  }

  Future<void> assignUserRole(String userId, String role) async {
    await _supabaseClient.from('user_roles').insert({
      'user_id': userId,
      'role': role,
    });
  }
}
