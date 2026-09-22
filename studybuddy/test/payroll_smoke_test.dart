import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/app/routes.dart';
import 'package:studybuddy/controllers/payroll_controller.dart';
import 'package:studybuddy/models/payroll_model.dart';
import 'package:studybuddy/views/tutor/payroll_screen.dart';
import 'package:studybuddy/views/tutor/slip_gaji_screen.dart';

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan.
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
    Get.put(PayrollController());
  });

  tearDown(Get.reset);

  testWidgets('PayrollScreen menampilkan saldo & riwayat slip', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: PayrollScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Saldo Belum Dibayar'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Agustus 2026'), findsOneWidget);
    expect(find.text('Belum Dibayar'), findsOneWidget);
    expect(find.text('Sudah Dibayar'), findsOneWidget);
  });

  testWidgets('Tap Lihat Slip navigasi ke SlipGajiScreen dengan rincian', (
    tester,
  ) async {
    // PayrollScreen navigasi pakai Get.toNamed(), jadi getPages perlu
    // didaftarkan supaya route "/tutor/slip-gaji" bisa di-resolve.
    await tester.pumpWidget(
      GetMaterialApp(
        home: const PayrollScreen(),
        getPages: [
          GetPage(name: AppRoutes.slipGaji, page: () => const SlipGajiScreen()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Slip').first);
    await tester.pumpAndSettle();

    expect(find.byType(SlipGajiScreen), findsOneWidget);
    expect(find.text('Arif Rahmat'), findsOneWidget);
    expect(find.text('Rekonsiliasi'), findsOneWidget);
  });

  test('totalHakTutor & remainingBalance dihitung benar', () {
    final record = PayrollRecordModel(
      id: 'p1',
      tutorId: 't1',
      tutorName: 'Tutor Uji',
      period: 'Test',
      totalTransferred: 50000,
      sessions: [
        SessionEarningItem(
          classDate: DateTime(2026, 1, 1),
          buddyName: 'Buddy A',
          material: 'Materi A',
          sessionCount: 2,
          ratePerSession: 30000,
          deduction: 5000,
        ),
      ],
    );

    expect(record.totalHakTutor, 55000); // (2*30000) - 5000
    expect(record.remainingBalance, 5000); // 55000 - 50000
  });

  testWidgets(
    'Saldo belum dibayar yang secara data negatif tetap tampil positif',
    (tester) async {
      // Simulasi data tidak konsisten (mis. totalTransferred > totalHakTutor
      // dari sumber asli) — kartu saldo tidak boleh menampilkan minus.
      final ctrl = Get.find<PayrollController>();
      ctrl.records.add(
        PayrollRecordModel(
          id: 'p-negative',
          tutorId: 'tutor-me',
          tutorName: 'Arif Rahmat',
          period: 'Negative Test',
          status: PayrollStatus.belumDibayar,
          totalTransferred: 999999,
          sessions: [
            SessionEarningItem(
              classDate: DateTime(2026, 1, 1),
              buddyName: 'Buddy Z',
              material: 'Materi Z',
              ratePerSession: 10000,
            ),
          ],
        ),
      );

      await tester.pumpWidget(const GetMaterialApp(home: PayrollScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('-'), findsNothing);
    },
  );

  testWidgets('SlipGajiScreen tanpa argumen tidak crash', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: SlipGajiScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Slip gaji tidak ditemukan'), findsOneWidget);
  });
}
