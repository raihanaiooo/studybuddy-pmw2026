import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Singleton wrapper untuk inisialisasi dan akses Supabase client
class SupabaseService {
  SupabaseService._();

  /// Inisialisasi Supabase saat app startup
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
  }

  /// Akses Supabase client global
  static SupabaseClient get client => Supabase.instance.client;

  /// Shortcut untuk auth client
  static GoTrueClient get auth => client.auth;
}
