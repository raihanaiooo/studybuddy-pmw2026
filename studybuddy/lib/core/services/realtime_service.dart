import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../constants/supabase_constants.dart';

/// Service untuk Supabase Realtime — online tutor & booking updates
class RealtimeService {
  RealtimeChannel? _onlineTutorChannel;
  RealtimeChannel? _bookingChannel;

  /// Subscribe perubahan status online tutor
  void subscribeOnlineTutors(void Function(List<dynamic>) onUpdate) {
    _onlineTutorChannel = SupabaseService.client
        .channel(SupabaseConstants.channelOnlineTutors)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseConstants.tableTutors,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'is_online',
            value: true,
          ),
          callback: (payload) async {
            final data = await SupabaseService.client
                .from(SupabaseConstants.tableTutors)
                .select()
                .eq('is_online', true)
                .eq('verification_status', 'verified')
                .order('rating', ascending: false);
            onUpdate(data);
          },
        )
        .subscribe();
  }

  /// Subscribe perubahan booking milik user tertentu (Wave 2.2).
  ///
  /// Kontrak isi event realtime booking (C-BOOK-06 / D-52) BELUM disepakati
  /// pemilik Back-End, sehingga isi payload TIDAK boleh diandalkan: callback
  /// hanya diberi tahu "ada perubahan" tanpa argumen, dan penerima wajib
  /// membaca ulang lewat jalur baca yang sudah terverifikasi.
  ///
  /// Filter memakai kedua kolom yang bentuknya TERVERIFIKASI oleh kode baca
  /// yang sudah berjalan (fetchMyBookings): `customer_id` untuk Buddy dan
  /// `tutor_id` untuk Tutor — tanpa mengasumsikan kolom atau relasi lain.
  ///
  /// Catatan jujur: konfigurasi publikasi realtime untuk tabel bookings
  /// tidak dapat diverifikasi dari repo (tidak ada artefak backend), jadi
  /// event bisa saja tidak pernah tiba — perilaku bawaan aplikasi tetap
  /// fetch-on-init yang sudah terverifikasi.
  void subscribeBookings({
    required String customerId,
    required String tutorId,
    required void Function() onChanged,
  }) {
    final channel = SupabaseService.client.channel(
      SupabaseConstants.channelBookings,
    );
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.tableBookings,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) => onChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.tableBookings,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tutor_id',
            value: tutorId,
          ),
          callback: (_) => onChanged(),
        )
        .subscribe();
    _bookingChannel = channel;
  }

  /// Lepas langganan channel booking tanpa menyentuh channel online tutors
  /// (dipakai controller yang hanya berlangganan booking).
  Future<void> unsubscribeBookings() async {
    await _bookingChannel?.unsubscribe();
    _bookingChannel = null;
  }

  /// Unsubscribe semua channel saat widget dispose
  Future<void> dispose() async {
    await _onlineTutorChannel?.unsubscribe();
    await unsubscribeBookings();
  }
}
