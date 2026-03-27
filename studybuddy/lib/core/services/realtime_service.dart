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
                .select('*, users(*)')
                .eq('is_online', true);
            onUpdate(data);
          },
        )
        .subscribe();
  }

  /// Subscribe perubahan booking milik user tertentu
  void subscribeBookings(String userId, void Function(dynamic) onUpdate) {
    _bookingChannel = SupabaseService.client
        .channel(SupabaseConstants.channelBookings)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.tableBookings,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload),
        )
        .subscribe();
  }

  /// Unsubscribe semua channel saat widget dispose
  Future<void> dispose() async {
    await _onlineTutorChannel?.unsubscribe();
    await _bookingChannel?.unsubscribe();
  }
}
