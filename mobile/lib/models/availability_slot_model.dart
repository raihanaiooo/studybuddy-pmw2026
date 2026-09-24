class AvailabilitySlotModel {
  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const AvailabilitySlotModel({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.status = 'available',
  });

  factory AvailabilitySlotModel.fromMap(Map<String, dynamic> map) =>
      AvailabilitySlotModel(
        id: map['id'] as String,
        tutorId: map['tutor_id'] as String,
        startTime: _parseDateTime(map['start_time']),
        endTime: _parseDateTime(map['end_time']),
        status: map['status'] as String? ?? 'available',
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tutor_id': tutorId,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'status': status,
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
