import 'slot_booking_policy.dart' show AvailabilitySlotRef;

abstract class AvailabilitySlotRepository {
  Future<List<AvailabilitySlotRef>> fetchTutorSlots(String tutorId);
  Future<AvailabilitySlotRef> createSlot(AvailabilitySlotDraft draft);
  Future<void> deleteSlot(String slotId);
  Future<BookingSlotOutcome> bookSlot({
    required String slotId,
    required Map<String, dynamic> bookingValues,
  });
}

class AvailabilitySlotDraft {
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;

  const AvailabilitySlotDraft({
    required this.tutorId,
    required this.startTime,
    required this.endTime,
  });
}

enum BookingSlotFailureReason { taken }

class BookingSlotOutcome {
  final bool success;
  final BookingSlotFailureReason? failureReason;

  const BookingSlotOutcome._(this.success, this.failureReason);

  const BookingSlotOutcome.success() : this._(true, null);

  const BookingSlotOutcome.taken()
    : this._(false, BookingSlotFailureReason.taken);
}

class AvailabilitySlotBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const AvailabilitySlotBackendMissingException(this.message, [this.cause]);

  @override
  String toString() =>
      'AvailabilitySlotBackendMissingException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
