import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/reschedule_controller.dart';
import 'package:studybuddy/models/booking_model.dart';
import 'package:studybuddy/models/reschedule_model.dart';
import 'package:studybuddy/views/customer/reschedule_screen.dart';

final _dummyBooking = BookingModel(
  id: 'booking-1',
  customerId: 'customer-1',
  tutorId: 'tutor-1',
  // > H-6 jam dari sekarang, supaya default-nya lolos auto-approve
  sessionTime: DateTime.now().add(const Duration(days: 1)),
  durationMinutes: 60,
  subject: 'Kalkulus II',
  sessionType: 'video',
  status: 'confirmed',
  createdAt: DateTime.now(),
);

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan.
    await initializeDateFormatting('id', null);
  });

  group('RescheduleScreen (widget)', () {
    setUp(() {
      Get.testMode = true;
      Get.put(RescheduleController());
    });

    tearDown(Get.reset);

    Future<void> pumpRescheduleScreen(WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Container()));
      Get.to(() => const RescheduleScreen(), arguments: _dummyBooking);
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan jadwal semula & aturan', (tester) async {
      await pumpRescheduleScreen(tester);

      expect(find.text('Kalkulus II'), findsOneWidget);
      expect(
        find.textContaining('Sisa kuota reschedule kamu: 3x'),
        findsOneWidget,
      );
    });

    testWidgets('submit tanpa pilih tanggal/jam menampilkan snackbar', (
      tester,
    ) async {
      await pumpRescheduleScreen(tester);

      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Ajukan Reschedule',
      );
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pump();

      // Belum isi tanggal/jam -> _submit menahan di Get.snackbar tanpa
      // memanggil controller, jadi form tetap di screen yang sama
      // (bukan lanjut ke dialog hasil approval).
      expect(find.text('Pilih tanggal'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Get.snackbar() bikin Timer auto-dismiss — biarkan settle penuh.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  // Logic murni FR-RESCH-02..06 — pakai instance controller langsung
  // tanpa GetX DI, karena tidak butuh widget tree sama sekali.
  group('RescheduleController (logic)', () {
    test('reschedule normal (> H-6 jam) langsung disetujui otomatis', () {
      final ctrl = RescheduleController();
      final quotaBefore = ctrl.quotaLeft.value;

      final result = ctrl.submitReschedule(
        bookingId: _dummyBooking.id,
        originalSessionTime: _dummyBooking.sessionTime,
        newSessionTime: _dummyBooking.sessionTime.add(
          const Duration(hours: 2),
        ),
        reason: 'Ada acara keluarga',
      );

      expect(result, isNotNull);
      expect(result!.status, RescheduleStatus.disetujui);
      expect(ctrl.quotaLeft.value, quotaBefore - 1);
      expect(ctrl.myRequests.first.id, result.id);
    });

    test('reschedule < H-6 jam butuh approval Admin', () {
      final ctrl = RescheduleController();
      final soonSession = DateTime.now().add(const Duration(hours: 2));

      final result = ctrl.submitReschedule(
        bookingId: 'booking-urgent',
        originalSessionTime: soonSession,
        newSessionTime: soonSession.add(const Duration(hours: 3)),
        reason: 'Mendadak ada kepentingan',
      );

      expect(result, isNotNull);
      expect(result!.status, RescheduleStatus.menungguAdmin);
      expect(result.adminNote, contains('H-6 jam'));
    });

    test('pengalihan ke Tutor lain butuh approval Admin walau > H-6 jam', () {
      final ctrl = RescheduleController();

      final result = ctrl.submitReschedule(
        bookingId: _dummyBooking.id,
        originalSessionTime: _dummyBooking.sessionTime,
        newSessionTime: _dummyBooking.sessionTime.add(
          const Duration(hours: 2),
        ),
        reason: 'Tutor asli berhalangan',
        switchTutor: true,
      );

      expect(result, isNotNull);
      expect(result!.status, RescheduleStatus.menungguAdmin);
      expect(result.adminNote, contains('Tutor lain'));
    });

    test('kuota habis butuh approval Admin', () {
      final ctrl = RescheduleController();
      ctrl.quotaLeft.value = 0;

      final result = ctrl.submitReschedule(
        bookingId: _dummyBooking.id,
        originalSessionTime: _dummyBooking.sessionTime,
        newSessionTime: _dummyBooking.sessionTime.add(
          const Duration(hours: 2),
        ),
        reason: 'Sudah 3x reschedule bulan ini',
      );

      expect(result, isNotNull);
      expect(result!.status, RescheduleStatus.menungguAdmin);
      expect(result.adminNote, contains('Kuota'));
    });

    test('jadwal baru lebih dari H+2 hari ditolak validasi', () {
      final ctrl = RescheduleController();

      final result = ctrl.submitReschedule(
        bookingId: _dummyBooking.id,
        originalSessionTime: _dummyBooking.sessionTime,
        newSessionTime: _dummyBooking.sessionTime.add(
          const Duration(days: 5),
        ),
        reason: 'Coba lewat batas',
      );

      expect(result, isNull);
      expect(ctrl.errorMessage.value, contains('2 hari'));
    });

    test('alasan kosong ditolak validasi', () {
      final ctrl = RescheduleController();

      final result = ctrl.submitReschedule(
        bookingId: _dummyBooking.id,
        originalSessionTime: _dummyBooking.sessionTime,
        newSessionTime: _dummyBooking.sessionTime.add(
          const Duration(hours: 2),
        ),
        reason: '   ',
      );

      expect(result, isNull);
      expect(ctrl.errorMessage.value, isNotEmpty);
    });
  });
}
