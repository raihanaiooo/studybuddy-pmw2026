import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../domain/package_repository.dart';

class PackageRepositorySupabase implements PackageRepository {
  static const String _tablePackages = 'packages';
  static const String _tableTokens = 'tokens';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<PackageRef>> fetchActivePackages() async {
    final data = await _client
        .from(_tablePackages)
        .select()
        .eq('is_active', true)
        .order('price', ascending: true);
    return (data as List).map((e) => _toPackageRef(e)).toList();
  }

  @override
  Future<List<TokenRef>> fetchMyTokens(String buddyId) async {
    final data = await _client
        .from(_tableTokens)
        .select()
        .eq('buddy_id', buddyId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => _toTokenRef(e)).toList();
  }

  @override
  Future<TokenRef> createToken({
    required String buddyId,
    required String packageId,
    required int sessionCount,
    required int validityDays,
  }) async {
    final now = DateTime.now();
    final data = await _client
        .from(_tableTokens)
        .insert({
          'buddy_id': buddyId,
          'package_id': packageId,
          'status': 'active',
          'active_date': now.toIso8601String(),
          'expiry_date': now
              .add(Duration(days: validityDays))
              .toIso8601String(),
          'sessions_remaining': sessionCount,
        })
        .select()
        .single();
    return _toTokenRef(data);
  }

  @override
  Future<void> consumeToken(String tokenId) async {
    final token = await _client
        .from(_tableTokens)
        .select('sessions_remaining')
        .eq('id', tokenId)
        .single();
    final remaining = token['sessions_remaining'] as int;
    final newRemaining = remaining - 1;
    await _client
        .from(_tableTokens)
        .update({
          'sessions_remaining': newRemaining,
          'status': newRemaining <= 0 ? 'used' : 'active',
        })
        .eq('id', tokenId);
  }

  @override
  Future<void> expireOldTokens() async {
    await _client
        .from(_tableTokens)
        .update({'status': 'expired'})
        .eq('status', 'active')
        .lt('expiry_date', DateTime.now().toIso8601String());
  }

  PackageRef _toPackageRef(dynamic e) {
    final map = e as Map<String, dynamic>;
    return PackageRef(
      id: map['id'] as String,
      packageName: map['package_name'] as String,
      sessionCount: map['session_count'] as int,
      validityDays: map['validity_days'] as int,
      rescheduleQuota: map['reschedule_quota'] as int,
      isRefundable: map['is_refundable'] as bool,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  TokenRef _toTokenRef(dynamic e) {
    final map = e as Map<String, dynamic>;
    return TokenRef(
      id: map['id'] as String,
      buddyId: map['buddy_id'] as String,
      packageId: map['package_id'] as String,
      status: map['status'] as String,
      activeDate: _parseDateTime(map['active_date']),
      expiryDate: _parseDateTime(map['expiry_date']),
      sessionsRemaining: map['sessions_remaining'] as int,
    );
  }

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
}
