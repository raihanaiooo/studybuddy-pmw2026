import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../domain/meet_link_repository.dart';

class MeetLinkRepositorySupabase implements MeetLinkRepository {
  static const String _table = 'tutor_meet_links';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<MeetLinkRef>> fetchLinks(String tutorId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('tutor_id', tutorId)
          .eq('is_active', true)
          .order('created_at', ascending: true);
      return (data as List)
          .map((e) => _toRef(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<MeetLinkRef> createLink({
    required String tutorId,
    required String meetLink,
    String? label,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .insert({
            'tutor_id': tutorId,
            'meet_link': meetLink,
            'label': label,
            'is_active': true,
          })
          .select()
          .single();
      return _toRef(data);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<void> deleteLink(String linkId) async {
    try {
      await _client.from(_table).delete().eq('id', linkId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<MeetLinkRef?> pickOneActive(String tutorId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('tutor_id', tutorId)
          .eq('is_active', true)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();
      if (data == null) return null;
      return _toRef(data);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  MeetLinkRef _toRef(Map<String, dynamic> map) => MeetLinkRef(
    id: map['id'] as String,
    tutorId: map['tutor_id'] as String,
    meetLink: map['meet_link'] as String,
    label: map['label'] as String?,
    isActive: map['is_active'] as bool? ?? true,
    createdAt: _parseDateTime(map['created_at']),
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

  MeetLinkBackendMissingException _wrapMissing(PostgrestException e) {
    final m = e.message.toLowerCase();
    final missing =
        m.contains('does not exist') ||
        m.contains('could not find the table') ||
        m.contains('schema cache');
    return missing
        ? MeetLinkBackendMissingException(
            'Tabel tutor_meet_links tidak dikenal backend: ${e.message}',
            e,
          )
        : MeetLinkBackendMissingException(
            'Operasi link Meet gagal: ${e.message}',
            e,
          );
  }
}
