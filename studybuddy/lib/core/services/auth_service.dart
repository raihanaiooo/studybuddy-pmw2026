import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import 'supabase_service.dart';
import '../../models/user_model.dart';

class AuthService {
  SupabaseClient get _client => SupabaseService.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String phone,
    String? jenjang,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );

    if (response.user == null) throw Exception('Registrasi gagal: user null');

    final userData = {
      'id': response.user!.id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'jenjang': jenjang,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _client.from(SupabaseConstants.tableUsers).insert(userData);

    return UserModel.fromMap(userData);
  }

  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final data = await _client
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('id', authUser.id)
        .single();

    return UserModel.fromMap(data);
  }

  Future<void> updateOnlineStatus({
    required String tutorId,
    required bool isOnline,
  }) async {
    await _client
        .from(SupabaseConstants.tableTutors)
        .update({
          'is_online': isOnline,
          'last_seen': DateTime.now().toIso8601String(),
        })
        .eq('user_id', tutorId);
  }
}
