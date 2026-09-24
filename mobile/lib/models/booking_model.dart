class BookingModel {
  final String id;
  final String customerId;
  final String tutorId;
  final String? slotId;
  final DateTime sessionTime;
  final int durationMinutes;
  final String subject;
  final String sessionType;
  final String status;
  final String? notes;
  final DateTime createdAt;

  // Dari join tutors(*)
  final String? tutorFullName;
  final String? tutorAvatarUrl;
  final List<String> tutorSubjects;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.tutorId,
    this.slotId,
    required this.sessionTime,
    required this.durationMinutes,
    required this.subject,
    required this.sessionType,
    required this.status,
    this.notes,
    required this.createdAt,
    this.tutorFullName,
    this.tutorAvatarUrl,
    this.tutorSubjects = const [],
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final tutorJoin = map['tutors'] as Map<String, dynamic>?;
    return BookingModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      tutorId: map['tutor_id'] as String,
      slotId: map['slot_id'] as String?,
      sessionTime: _parseDateTime(map['session_time']),
      durationMinutes: map['duration_minutes'] as int? ?? 60,
      subject: map['subject'] as String,
      sessionType: map['session_type'] as String? ?? 'video',
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: _parseDateTime(map['created_at']),
      tutorFullName: tutorJoin?['full_name'] as String?,
      tutorAvatarUrl: tutorJoin?['avatar_url'] as String?,
      tutorSubjects: List<String>.from(tutorJoin?['subjects'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_id': customerId,
    'tutor_id': tutorId,
    'slot_id': slotId,
    'session_time': sessionTime.toIso8601String(),
    'duration_minutes': durationMinutes,
    'subject': subject,
    'session_type': sessionType,
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

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
