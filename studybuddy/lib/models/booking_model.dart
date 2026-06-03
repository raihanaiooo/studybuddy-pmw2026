/// Model data pemesanan sesi tutor
class BookingModel {
  final String id;
  final String customerId;
  final String tutorId;
  final String? customerName; // join dari tabel users
  final DateTime sessionDate;
  final String startTime; // "08:00:00"
  final String endTime; // "10:00:00"
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
    this.customerName,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.subject,
    required this.sessionType,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  /// Jam durasi untuk ditampilkan di UI: "2 jam"
  int get durationHours => (durationMinutes / 60).round();

  /// Alias untuk backward compatibility — gabungan sessionDate + startTime
  DateTime get sessionTime {
    final parts = startTime.split(':');
    return DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    // Support dua format: session_time (lama) atau session_date + start_time (baru)
    DateTime sessionDate;
    String startTime;
    String endTime;
    int durationMinutes;

    if (map.containsKey('session_date')) {
      sessionDate = DateTime.parse(map['session_date'] as String);
      startTime = map['start_time'] as String? ?? '08:00:00';
      endTime = map['end_time'] as String? ?? '10:00:00';
      durationMinutes = map['duration_minutes'] as int? ?? 60;
    } else {
      // Legacy: session_time → derive fields
      final dt = DateTime.parse(map['session_time'] as String);
      sessionDate = DateTime(dt.year, dt.month, dt.day);
      durationMinutes = map['duration_minutes'] as int? ?? 60;
      startTime =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
      final endDt = dt.add(Duration(minutes: durationMinutes));
      endTime =
          '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}:00';
    }

    // customerName bisa dari join: map['users']['full_name']
    String? customerName;
    if (map['users'] != null && map['users'] is Map) {
      customerName = (map['users'] as Map)['full_name'] as String?;
    } else {
      customerName = map['customer_name'] as String?;
    }

    return BookingModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      tutorId: map['tutor_id'] as String,
      customerName: customerName,
      sessionDate: sessionDate,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      subject: map['subject'] as String,
      sessionType: map['session_type'] as String? ?? 'video',
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_id': customerId,
    'tutor_id': tutorId,
    'customer_name': customerName,
    'session_date': sessionDate.toIso8601String().split('T')[0],
    'start_time': startTime,
    'end_time': endTime,
    'duration_minutes': durationMinutes,
    'subject': subject,
    'session_type': sessionType,
    'status': status,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? tutorId,
    String? customerName,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    String? subject,
    String? sessionType,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) => BookingModel(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    tutorId: tutorId ?? this.tutorId,
    customerName: customerName ?? this.customerName,
    sessionDate: sessionDate ?? this.sessionDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    subject: subject ?? this.subject,
    sessionType: sessionType ?? this.sessionType,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}
