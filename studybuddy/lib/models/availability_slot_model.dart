/// Slot jadwal ketersediaan yang diatur Tutor sendiri (FR-BOOK-01)
class AvailabilitySlotModel {
  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final String timezone; // WIB | WITA | WIT
  final String status; // 'available' | 'booked'

  const AvailabilitySlotModel({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.timezone = 'WIB',
    this.status = 'available',
  });

  factory AvailabilitySlotModel.fromMap(Map<String, dynamic> map) =>
      AvailabilitySlotModel(
        id: map['id'] as String,
        tutorId: map['tutor_id'] as String,
        startTime: DateTime.parse(map['waktu_mulai'] as String),
        endTime: DateTime.parse(map['waktu_selesai'] as String),
        timezone: map['zona_waktu'] as String? ?? 'WIB',
        status: map['status'] as String? ?? 'available',
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tutor_id': tutorId,
    'waktu_mulai': startTime.toIso8601String(),
    'waktu_selesai': endTime.toIso8601String(),
    'zona_waktu': timezone,
    'status': status,
  };
}
