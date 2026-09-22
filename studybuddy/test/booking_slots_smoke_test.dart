import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/booking_controller.dart';
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

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan.
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
    Get.put(BookingController());
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
    expect(ctrl.availableSlots, isNotEmpty);

    final firstSlot = ctrl.availableSlots.first;
    await tester.tap(find.byKey(ValueKey('slot-${firstSlot.id}')));
    await tester.pumpAndSettle();

    expect(ctrl.selectedSlot.value?.id, firstSlot.id);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Konfirmasi Booking'),
    );
    expect(button.onPressed, isNotNull);
  });
}
