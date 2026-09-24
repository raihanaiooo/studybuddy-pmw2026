/// Status persetujuan pengajuan reschedule
enum RescheduleStatus { menungguAdmin, disetujui, ditolak }

/// Pengajuan reschedule sesi
class RescheduleModel {
  final String id;
  final String bookingId;
  final String requestedBy;
  final String reason;
  final DateTime originalSessionTime;
  final DateTime newSessionTime;
  final RescheduleStatus status;
  final String requestedByRole;
  final String? adminNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const RescheduleModel({
    required this.id,
    required this.bookingId,
    required this.requestedBy,
    required this.reason,
    required this.originalSessionTime,
    required this.newSessionTime,
    required this.status,
    this.requestedByRole = 'buddy',
    this.adminNote,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory RescheduleModel.fromMap(Map<String, dynamic> map) => RescheduleModel(
    id: map['id'] as String,
    bookingId: map['booking_id'] as String,
    requestedBy: map['requested_by'] as String,
    reason: map['reason'] as String,
    originalSessionTime: _parseDateTime(map['original_session_time']),
    newSessionTime: _parseDateTime(map['new_session_time']),
    status: _statusFromString(map['status'] as String?),
    requestedByRole: map['requested_by_role'] as String? ?? 'buddy',
    adminNote: map['admin_note'] as String?,
    reviewedBy: map['reviewed_by'] as String?,
    reviewedAt: map['reviewed_at'] != null
        ? _parseDateTime(map['reviewed_at'])
        : null,
    createdAt: _parseDateTime(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'booking_id': bookingId,
    'requested_by': requestedBy,
    'reason': reason,
    'original_session_time': originalSessionTime.toIso8601String(),
    'new_session_time': newSessionTime.toIso8601String(),
    'status': _statusToString(status),
    'requested_by_role': requestedByRole,
    'admin_note': adminNote,
    'reviewed_by': reviewedBy,
    'reviewed_at': reviewedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  static RescheduleStatus _statusFromString(String? value) {
    switch (value) {
      case 'disetujui':
        return RescheduleStatus.disetujui;
      case 'ditolak':
        return RescheduleStatus.ditolak;
      case 'menunggu_admin':
      default:
        return RescheduleStatus.menungguAdmin;
    }
  }

  static String _statusToString(RescheduleStatus s) {
    switch (s) {
      case RescheduleStatus.menungguAdmin:
        return 'menunggu_admin';
      case RescheduleStatus.disetujui:
        return 'disetujui';
      case RescheduleStatus.ditolak:
        return 'ditolak';
    }
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
