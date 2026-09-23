class SessionModel {
  final String id;
  final String bookingId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String? gmeetLink;
  final int elapsedSeconds;

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
    startTime: _parseDateTime(map['start_time']),
    endTime: map['end_time'] != null ? _parseDateTime(map['end_time']) : null,
    status: map['status'] as String? ?? 'scheduled',
    gmeetLink: map['gmeet_link'] as String?,
    elapsedSeconds: map['elapsed_seconds'] as int? ?? 0,
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
}
