import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import 'supabase_service.dart';
import '../../models/user_model.dart';

/// Service layer untuk semua operasi autentikasi via Supabase Auth
class AuthService {
  final _client = SupabaseService.client;

  /// Login dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registrasi user baru, simpan data ke tabel users
  // Future<UserModel> signUp({
  //   required String email,
  //   required String password,
  //   required String fullName,
  //   required String role, // 'customer' | 'tutor'
  // }) async {
  //   final response = await _client.auth.signUp(
  //     email: email,
  //     password: password,
  //     data: {'full_name': fullName, 'role': role},
  //   );

  //   if (response.user == null) throw Exception('Registrasi gagal');

  //   final userData = {
  //     'id': response.user!.id,
  //     'email': email,
  //     'full_name': fullName,
  //     'role': role,
  //     'created_at': DateTime.now().toIso8601String(),
  //   };

  //   await _client.from(SupabaseConstants.tableUsers).insert(userData);

  //   return UserModel.fromMap(userData);
  // }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );

      print('=== SIGNUP RESPONSE ===');
      print('User: ${response.user}');
      print('Session: ${response.session}');

      if (response.user == null) throw Exception('Registrasi gagal: user null');

      final userData = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('=== INSERTING USER DATA ===');
      print(userData);

      final insertResult = await _client
          .from(SupabaseConstants.tableUsers)
          .insert(userData);

      print('=== INSERT RESULT ===');
      print(insertResult);

      return UserModel.fromMap(userData);
    } catch (e, stack) {
      print('=== SIGNUP ERROR ===');
      print('Error: $e');
      print('Stack: $stack');
      rethrow;
    }
  }

  /// Logout user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Ambil data user yang sedang login dari tabel users
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

  /// Update status online tutor
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
