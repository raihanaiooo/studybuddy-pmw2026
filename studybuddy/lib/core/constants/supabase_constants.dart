/// Konfigurasi koneksi Supabase — isi sesuai project kamu
class SupabaseConstants {
  SupabaseConstants._();

  // Ganti dengan URL & anon key dari dashboard Supabase
  static const String supabaseUrl = 'https://seytkacajhoplswgyodj.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_a1cQV69su7QTF1vE5QtlCg_a6MhIEXl';

  // Nama tabel PostgreSQL
  static const String tableUsers = 'users';
  static const String tableTutors = 'tutors';
  static const String tableBookings = 'bookings';
  static const String tableSessions = 'sessions';
  static const String tableReviews = 'reviews';

  // Supabase Storage bucket
  static const String bucketAvatars = 'avatars';
  static const String bucketDocuments = 'documents';

  // Realtime channel names
  static const String channelOnlineTutors = 'online-tutors';
  static const String channelBookings = 'bookings-changes';
}
