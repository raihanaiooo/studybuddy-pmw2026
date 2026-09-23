library;

abstract final class SlotStatus {
  static const String available = 'available';
  static const String locked = 'locked';
  static const String booked = 'booked';
  static const String cancelled = 'cancelled';
}

class AvailabilitySlotRef {
  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const AvailabilitySlotRef({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.status = SlotStatus.available,
  });
}

abstract final class SlotBookingPolicy {
  static const Duration minimumLeadTime = Duration(hours: 5);

  static bool isBookingTimeValid(DateTime sessionTime, {DateTime? now}) {
    final nowDt = now ?? DateTime.now();
    return sessionTime.isAfter(nowDt.add(minimumLeadTime));
  }

  static bool isSelectableForBooking(
    AvailabilitySlotRef slot, {
    DateTime? now,
  }) =>
      slot.status == SlotStatus.available &&
      isBookingTimeValid(slot.startTime, now: now);

  static bool isSlotConsumableByBooking(AvailabilitySlotRef slot) =>
      slot.status == SlotStatus.available;

  static int sessionDurationMinutes(AvailabilitySlotRef slot) =>
      slot.endTime.difference(slot.startTime).inMinutes;

  static bool isSessionStarted(AvailabilitySlotRef slot, {DateTime? now}) {
    final nowDt = now ?? DateTime.now();
    return !slot.startTime.isAfter(nowDt);
  }

  static bool isRemovableByTutor(AvailabilitySlotRef slot) =>
      slot.status == SlotStatus.available ||
      slot.status == SlotStatus.cancelled;
}
