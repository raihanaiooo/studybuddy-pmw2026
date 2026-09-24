/// Model token belajar hasil pembelian paket
/// 1 token = beberapa sesi (sesuai paket), ada kadaluarsa
class TokenModel {
  final String id;
  final String buddyId;
  final String packageId;
  final String status; // 'active' | 'used' | 'expired'
  final DateTime activeDate;
  final DateTime expiryDate;
  final int sessionsRemaining;

  const TokenModel({
    required this.id,
    required this.buddyId,
    required this.packageId,
    required this.status,
    required this.activeDate,
    required this.expiryDate,
    this.sessionsRemaining = 0,
  });

  factory TokenModel.fromMap(Map<String, dynamic> map) => TokenModel(
    id: map['id'] as String,
    buddyId: map['buddy_id'] as String,
    packageId: map['package_id'] as String,
    status: map['status'] as String? ?? 'active',
    activeDate: _parseDateTime(map['active_date']),
    expiryDate: _parseDateTime(map['expiry_date']),
    sessionsRemaining: map['sessions_remaining'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'buddy_id': buddyId,
    'package_id': packageId,
    'status': status,
    'active_date': activeDate.toIso8601String(),
    'expiry_date': expiryDate.toIso8601String(),
    'sessions_remaining': sessionsRemaining,
  };

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  bool get isUsable =>
      status == 'active' && sessionsRemaining > 0 && daysLeft >= 0;

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
