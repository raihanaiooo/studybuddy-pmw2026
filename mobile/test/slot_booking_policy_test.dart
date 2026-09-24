import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/slot_booking_policy.dart';

/// Aturan slot & booking murni Dart — diuji tanpa Supabase/Flutter binding.
void main() {
  final base = DateTime(2026, 9, 23, 9, 0);

  AvailabilitySlotRef slot({
    String id = 'slot-1',
    String status = SlotStatus.available,
    DateTime? start,
    DateTime? end,
    String tutorId = 'tutor-1',
  }) => AvailabilitySlotRef(
    id: id,
    tutorId: tutorId,
    startTime: start ?? base.add(const Duration(days: 1)),
    endTime: end ?? base.add(const Duration(days: 1, hours: 1)),
    status: status,
  );

  group('SlotBookingPolicy.isBookingTimeValid (H-5, SRS)', () {
    test('menolak booking kurang dari 5 jam sebelum sesi', () {
      final t = base.add(const Duration(hours: 4, minutes: 59));
      expect(
        SlotBookingPolicy.isBookingTimeValid(t, now: base),
        isFalse,
        reason: 'SRS: booking minimal 5 jam sebelum sesi',
      );
    });

    test('menerima booking tepat lebih dari 5 jam sebelum sesi', () {
      final t = base.add(const Duration(hours: 5, seconds: 1));
      expect(SlotBookingPolicy.isBookingTimeValid(t, now: base), isTrue);
    });

    test('menolak waktu yang sudah lewat', () {
      final t = base.subtract(const Duration(hours: 1));
      expect(SlotBookingPolicy.isBookingTimeValid(t, now: base), isFalse);
    });
  });

  group('SlotBookingPolicy.isSelectableForBooking (FR-BOOK-04)', () {
    test('slot available di dalam jendela H-5 bisa dipilih', () {
      final s = slot(start: base.add(const Duration(days: 1)));
      expect(
        SlotBookingPolicy.isSelectableForBooking(s, now: base),
        isTrue,
      );
    });

    test('slot booked TIDAK bisa dipilih meski waktunya valid', () {
      final s = slot(status: SlotStatus.booked);
      expect(
        SlotBookingPolicy.isSelectableForBooking(s, now: base),
        isFalse,
        reason: 'SRS: slot terbooking tidak boleh dipilih Buddy lain',
      );
    });

    test('slot available tetapi di luar jendela H-5 TIDAK bisa dipilih', () {
      final s = slot(start: base.add(const Duration(hours: 2)));
      expect(
        SlotBookingPolicy.isSelectableForBooking(s, now: base),
        isFalse,
      );
    });
  });

  group('SlotBookingPolicy.isSlotConsumableByBooking (FR-BOOK-05)', () {
    test('hanya slot available yang boleh dikonsumsi booking', () {
      expect(
        SlotBookingPolicy.isSlotConsumableByBooking(
          slot(status: SlotStatus.available),
        ),
        isTrue,
      );
      expect(
        SlotBookingPolicy.isSlotConsumableByBooking(
          slot(status: SlotStatus.booked),
        ),
        isFalse,
        reason: 'mencegah double booking pada slot yang sama',
      );
    });
  });

  group('SlotBookingPolicy.sessionDurationMinutes (inferensi kode)', () {
    test('durasi mengikuti lebar slot dalam menit', () {
      final s = slot(
        start: DateTime(2026, 9, 24, 9),
        end: DateTime(2026, 9, 24, 10, 30),
      );
      expect(SlotBookingPolicy.sessionDurationMinutes(s), 90);
    });
  });

  group('SlotBookingPolicy.isSessionStarted (FR-SESI-01/06)', () {
    test('belum mulai sebelum waktu terjadwal', () {
      final s = slot(start: base.add(const Duration(hours: 1)));
      expect(SlotBookingPolicy.isSessionStarted(s, now: base), isFalse);
    });

    test('mulai tepat pada waktu terjadwal', () {
      final s = slot(start: base);
      expect(SlotBookingPolicy.isSessionStarted(s, now: base), isTrue);
    });
  });

  group('SlotBookingPolicy.isRemovableByTutor (FR-BOOK-01/04)', () {
    test('slot booked tidak boleh dihapus Tutor', () {
      expect(
        SlotBookingPolicy.isRemovableByTutor(slot(status: SlotStatus.booked)),
        isFalse,
      );
    });

    test('slot available boleh dihapus Tutor', () {
      expect(
        SlotBookingPolicy.isRemovableByTutor(slot(status: SlotStatus.available)),
        isTrue,
      );
    });
  });
}
