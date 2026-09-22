import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/auth_controller.dart';
import 'package:studybuddy/controllers/booking_controller.dart';
import 'package:studybuddy/controllers/tutor_dashboard_controller.dart';
import 'package:studybuddy/controllers/tutor_schedule_controller.dart';
import 'package:studybuddy/models/user_model.dart';
import 'package:studybuddy/views/tutor/tutor_dashboard_screen.dart';
import 'package:studybuddy/views/tutor/tutor_schedule_screen.dart';

/// AuthController & BookingController memicu fetch ke Supabase saat
/// onInit (gagal di widget test karena belum diinisialisasi, lalu
/// ditangkap try/catch di masing-masing controller). Tunggu satu pump
/// dulu supaya fetch yang gagal itu selesai sebelum widget di-pump,
/// biar tidak balapan dengan state loading.
Future<void> _seedControllers(WidgetTester tester) async {
  final auth = Get.put(AuthController());
  Get.put(BookingController());
  Get.put(TutorDashboardController());
  Get.put(TutorScheduleController());
  await tester.pump();
  auth.currentUser.value = UserModel(
    id: 'tutor-me',
    email: 'tutor@studybuddy.test',
    fullName: 'Arif Rahmat',
    role: 'tutor',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan (lihat juga fix di lib/main.dart).
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('TutorDashboardScreen menampilkan statistik & link GMeet', (
    tester,
  ) async {
    await _seedControllers(tester);
    await tester.pumpWidget(const GetMaterialApp(home: TutorDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Halo, Kak Arif'), findsOneWidget);
    expect(find.text('Status Online'), findsOneWidget);
    expect(find.text('Rating Rata-rata'), findsOneWidget);
    expect(find.text('meet.google.com/arif-fis-xyz'), findsOneWidget);
    expect(
      find.text('Belum ada booking masuk yang perlu dikonfirmasi'),
      findsOneWidget,
    );
  });

  testWidgets('Update link GMeet lewat dialog mengubah nilai', (tester) async {
    await _seedControllers(tester);
    await tester.pumpWidget(const GetMaterialApp(home: TutorDashboardScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'meet.google.com/updated-link',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    final dashboard = Get.find<TutorDashboardController>();
    expect(dashboard.gmeetLinks.first, 'meet.google.com/updated-link');
  });

  testWidgets('TutorScheduleScreen tab Atur Ketersediaan menampilkan slot', (
    tester,
  ) async {
    await _seedControllers(tester);
    await tester.pumpWidget(const GetMaterialApp(home: TutorScheduleScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sesi Terjadwal'), findsOneWidget);
    expect(find.text('Atur Ketersediaan'), findsOneWidget);

    await tester.tap(find.text('Atur Ketersediaan'));
    await tester.pumpAndSettle();

    expect(find.text('Dibooking'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);
  });

  testWidgets('Hapus slot ketersediaan yang belum dibooking', (tester) async {
    await _seedControllers(tester);
    await tester.pumpWidget(const GetMaterialApp(home: TutorScheduleScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Atur Ketersediaan'));
    await tester.pumpAndSettle();

    final ctrl = Get.find<TutorScheduleController>();
    final before = ctrl.slots.length;

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(ctrl.slots.length, before - 1);
  });
}
