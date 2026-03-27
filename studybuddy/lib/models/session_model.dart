/// Model data sesi belajar yang sedang / sudah berlangsung
class SessionModel {
  final String id;
  final String bookingId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active' | 'ended'
  final String? gmeetLink;
  final int elapsedSeconds; // untuk chat timer

  const SessionModel({
    required this.id,
    required this.bookingId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.gmeetLink,
    this.elapsedSeconds = 0,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
    id: map['id'] as String,
    bookingId: map['booking_id'] as String,
    startTime: DateTime.parse(map['start_time'] as String),
    endTime: map['end_time'] != null
        ? DateTime.parse(map['end_time'] as String)
        : null,
    status: map['status'] as String? ?? 'active',
    gmeetLink: map['gmeet_link'] as String?,
    elapsedSeconds: map['elapsed_seconds'] as int? ?? 0,
  );
}
