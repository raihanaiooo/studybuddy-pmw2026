import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/supabase_service.dart';
import '../domain/availability_slot_repository.dart';
import '../domain/slot_booking_policy.dart';

class AvailabilitySlotRepositorySupabase implements AvailabilitySlotRepository {
  static const String _tableSlots = 'availability_slots';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<AvailabilitySlotRef>> fetchTutorSlots(String tutorId) async {
    try {
      final data = await _client
          .from(_tableSlots)
          .select()
          .eq('tutor_id', tutorId)
          .order('start_time', ascending: true);
      return (data as List)
          .map((e) => _toRef(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<AvailabilitySlotRef> createSlot(AvailabilitySlotDraft draft) async {
    try {
      final data = await _client
          .from(_tableSlots)
          .insert({
            'tutor_id': draft.tutorId,
            'start_time': draft.startTime.toIso8601String(),
            'end_time': draft.endTime.toIso8601String(),
            'status': SlotStatus.available,
          })
          .select()
          .single();
      return _toRef(data);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    try {
      await _client.from(_tableSlots).delete().eq('id', slotId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<BookingSlotOutcome> bookSlot({
    required String slotId,
    required Map<String, dynamic> bookingValues,
  }) async {
    try {
      final locked = await _client
          .from(_tableSlots)
          .update({'status': SlotStatus.booked})
          .eq('id', slotId)
          .eq('status', SlotStatus.available)
          .select()
          .maybeSingle();
      if (locked == null) {
        return const BookingSlotOutcome.taken();
      }

      final valuesWithSlot = {...bookingValues, 'slot_id': slotId};

      await _client
          .from(SupabaseConstants.tableBookings)
          .insert(valuesWithSlot);
      return const BookingSlotOutcome.success();
    } on PostgrestException catch (e) {
      try {
        await _client
            .from(_tableSlots)
            .update({'status': SlotStatus.available})
            .eq('id', slotId)
            .eq('status', SlotStatus.booked);
      } on PostgrestException {
        // best-effort compensation
      }
      throw _wrapMissing(e);
    }
  }

  AvailabilitySlotRef _toRef(Map<String, dynamic> map) => AvailabilitySlotRef(
    id: map['id'] as String,
    tutorId: map['tutor_id'] as String,
    startTime: _parseDateTime(map['start_time']),
    endTime: _parseDateTime(map['end_time']),
    status: map['status'] as String? ?? SlotStatus.available,
  );

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        var normalized = value.replaceFirst(' ', 'T');
        if (RegExp(r'[+-]\d{2}$').hasMatch(normalized)) {
          normalized = '${normalized}:00';
        }
        return DateTime.parse(normalized);
      }
    }
    return DateTime.now();
  }

  AvailabilitySlotBackendMissingException _wrapMissing(PostgrestException e) {
    final m = e.message.toLowerCase();
    final missing =
        m.contains('does not exist') ||
        m.contains('could not find the table') ||
        m.contains('schema cache');
    return missing
        ? AvailabilitySlotBackendMissingException(
            'Kontrak AvailabilitySlot tidak dikenal backend: ${e.message}',
            e,
          )
        : AvailabilitySlotBackendMissingException(
            'Operasi slot gagal: ${e.message}',
            e,
          );
  }
}
