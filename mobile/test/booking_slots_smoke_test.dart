import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/booking_controller.dart';
import 'package:studybuddy/domain/availability_slot_repository.dart';
import 'package:studybuddy/domain/slot_booking_policy.dart';
import 'package:studybuddy/models/tutor_model.dart';
import 'package:studybuddy/views/customer/booking_screen.dart';

const _dummyTutor = TutorModel(
  id: 'tutor-1',
  userId: 'user-1',
  fullName: 'Arif Rahmat',
  bio: 'Suka ngajar Kalkulus',
  subjects: ['Kalkulus', 'Fisika Dasar'],
  rating: 4.8,
  totalSessions: 30,
  totalReviews: 20,
  isOnline: true,
  pricePerHour: 50000,
  university: 'Polban',
  gpa: 3.7,
);

/// Fake repository slot — layar diuji dengan slot nyata yang disimulasikan
/// tanpa menyentuh Supabase (belum diinisialisasi di widget test). Satu slot
/// available (di luar jendela H-5) dan satu slot booked: keduanya TIDAK boleh
/// ditawarkan setelah penyaringan domain (SlotBookingPolicy, FR-BOOK-04).
class _FakeSlotRepository implements AvailabilitySlotRepository {
  @override
  Future<List<AvailabilitySlotRef>> fetchTutorSlots(String tutorId) async => [
    AvailabilitySlotRef(
      id: 'slot-fake-available',
      tutorId: tutorId,
      startTime: DateTime.now().add(const Duration(days: 5)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 1)),
    ),
    AvailabilitySlotRef(
      id: 'slot-fake-booked',
      tutorId: tutorId,
      startTime: DateTime.now().add(const Duration(days: 6)),
      endTime: DateTime.now().add(const Duration(days: 6, hours: 1)),
      status: SlotStatus.booked,
    ),
    AvailabilitySlotRef(
      id: 'slot-fake-too-soon',
      tutorId: tutorId,
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
    ),
  ];

  @override
  Future<AvailabilitySlotRef> createSlot(AvailabilitySlotDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> deleteSlot(String slotId) => throw UnimplementedError();

  @override
  Future<BookingSlotOutcome> bookSlot({
    required String slotId,
    required Map<String, dynamic> bookingValues,
  }) async => const BookingSlotOutcome.success();
}

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan.
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
    Get.put(
      BookingController(slotRepository: _FakeSlotRepository()),
    );
  });

  tearDown(Get.reset);

  /// BookingScreen membaca tutor dari Get.arguments (di-set saat
  /// navigasi), bukan lewat constructor — jadi di test kita perlu benar-
  /// benar push route via Get.to(), bukan pumpWidget(home: ...) langsung.
  Future<void> _pumpBookingScreen(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: Container()));
    Get.to(() => const BookingScreen(), arguments: _dummyTutor);
    await tester.pumpAndSettle();
  }

  testWidgets('BookingScreen menampilkan slot yang bisa dipilih', (
    tester,
  ) async {
    await _pumpBookingScreen(tester);

    expect(find.text('Arif Rahmat'), findsOneWidget);
    expect(find.text('Kalkulus'), findsWidgets);
    expect(find.text('Pilih Jadwal'), findsOneWidget);

    // Tombol submit disabled sebelum slot & mata kuliah dipilih lengkap
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Konfirmasi Booking'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Pilih slot mengaktifkan tombol Konfirmasi Booking', (
    tester,
  ) async {
    await _pumpBookingScreen(tester);

    final ctrl = Get.find<BookingController>();

    // Slot available di dalam jendela H-5 ditawarkan (FR-BOOK-02/04).
    expect(ctrl.availableSlots.map((s) => s.id), contains('slot-fake-available'));

    final firstSlot = ctrl.availableSlots.first;
    await tester.tap(find.byKey(ValueKey('slot-${firstSlot.id}')));
    await tester.pumpAndSettle();

    expect(ctrl.selectedSlot.value?.id, firstSlot.id);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Konfirmasi Booking'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Slot booked dan di luar H-5 tidak muncul sebagai pilihan', (
    tester,
  ) async {
    await _pumpBookingScreen(tester);

    final ctrl = Get.find<BookingController>();

    // FR-BOOK-04: penyaringan kini ada di domain (SlotBookingPolicy),
    // bukan lagi di UI — sebelum slice ini slot-nya dummy dan saringannya
    // hanya menyaring daftar yang sudah ditampilkan.
    expect(ctrl.availableSlots.map((s) => s.id), isNot(contains('slot-fake-booked')));
    expect(
      ctrl.availableSlots.map((s) => s.id),
      isNot(contains('slot-fake-too-soon')),
    );
    expect(ctrl.availableSlots.every((s) => s.status == SlotStatus.available),
        isTrue);
    expect(find.byKey(const ValueKey('slot-slot-fake-booked')), findsNothing);
  });
}
