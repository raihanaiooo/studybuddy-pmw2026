import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../domain/reschedule_repository.dart';
import '../models/reschedule_model.dart';

class RescheduleRepositorySupabase implements RescheduleRepository {
  static const String _table = 'reschedules';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<RescheduleModel>> fetchMyRequests(String userId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('requested_by', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => RescheduleModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RescheduleModel> submitRequest({
    required String bookingId,
    required String requestedBy,
    required String requestedByRole,
    required String reason,
    required DateTime originalSessionTime,
    required DateTime newSessionTime,
  }) async {
    final data = await _client
        .from(_table)
        .insert({
          'booking_id': bookingId,
          'requested_by': requestedBy,
          'requested_by_role': requestedByRole,
          'reason': reason,
          'original_session_time': originalSessionTime.toIso8601String(),
          'new_session_time': newSessionTime.toIso8601String(),
          'status': 'menunggu_admin',
        })
        .select()
        .single();
    return RescheduleModel.fromMap(data);
  }

  @override
  Future<int> countMyRequestsThisMonth(String userId) async {
    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final data = await _client
        .from(_table)
        .select('id')
        .eq('requested_by', userId)
        .gte('created_at', startOfMonth.toIso8601String());
    return (data as List).length;
  }
}
