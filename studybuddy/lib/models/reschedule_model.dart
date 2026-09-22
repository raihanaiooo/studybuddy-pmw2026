/// Status persetujuan pengajuan reschedule (FR-RESCH-04/06)
enum RescheduleStatus { diajukan, disetujui, ditolak, menungguAdmin }

/// Pengajuan reschedule sesi (FR-RESCH-01..09, entity Reschedule di SRS 4.1)
class RescheduleModel {
  final String id;
  final String bookingId;
  final String reason;
  final DateTime originalSessionTime;
  final DateTime newSessionTime;
  final RescheduleStatus status;
  final String requestedBy; // 'buddy' | 'tutor'
  final String? adminNote;
  final DateTime createdAt;

  const RescheduleModel({
    required this.id,
    required this.bookingId,
    required this.reason,
    required this.originalSessionTime,
    required this.newSessionTime,
    required this.status,
    this.requestedBy = 'buddy',
    this.adminNote,
    required this.createdAt,
  });

  factory RescheduleModel.fromMap(Map<String, dynamic> map) => RescheduleModel(
    id: map['id'] as String,
    bookingId: map['session_id'] as String,
    reason: map['alasan'] as String,
    originalSessionTime: DateTime.parse(map['jadwal_lama'] as String),
    newSessionTime: DateTime.parse(map['jadwal_baru'] as String),
    status: RescheduleStatus.values.firstWhere(
      (s) => s.name == map['status_approval'],
      orElse: () => RescheduleStatus.diajukan,
    ),
    requestedBy: map['diajukan_oleh'] as String? ?? 'buddy',
    adminNote: map['admin_note'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'session_id': bookingId,
    'alasan': reason,
    'jadwal_lama': originalSessionTime.toIso8601String(),
    'jadwal_baru': newSessionTime.toIso8601String(),
    'status_approval': status.name,
    'diajukan_oleh': requestedBy,
    'admin_note': adminNote,
    'created_at': createdAt.toIso8601String(),
  };
}
