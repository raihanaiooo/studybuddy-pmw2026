/// Model data pemesanan sesi tutor
class BookingModel {
  final String id;
  final String customerId;
  final String tutorId;
  final DateTime sessionTime;
  final int durationMinutes;
  final String subject;
  final String sessionType; // 'video' | 'chat'
  final String
  status; // 'pending' | 'confirmed' | 'ongoing' | 'done' | 'cancelled'
  final String? notes;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.tutorId,
    required this.sessionTime,
    required this.durationMinutes,
    required this.subject,
    required this.sessionType,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'] as String,
    customerId: map['customer_id'] as String,
    tutorId: map['tutor_id'] as String,
    sessionTime: DateTime.parse(map['session_time'] as String),
    durationMinutes: map['duration_minutes'] as int? ?? 60,
    subject: map['subject'] as String,
    sessionType: map['session_type'] as String? ?? 'video',
    status: map['status'] as String? ?? 'pending',
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_id': customerId,
    'tutor_id': tutorId,
    'session_time': sessionTime.toIso8601String(),
    'duration_minutes': durationMinutes,
    'subject': subject,
    'session_type': sessionType,
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
}
