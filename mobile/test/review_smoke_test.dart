import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:studybuddy/app/routes.dart';
import 'package:studybuddy/controllers/review_controller.dart';
import 'package:studybuddy/views/session/review_screen.dart';

/// ReviewController dipakai lewat spy supaya test bisa memastikan apa yang
/// (tidak) dikirim tanpa menyentuh Supabase, yang belum diinisialisasi di
/// widget test.
class _SpyReviewController extends ReviewController {
  final calls = <Map<String, Object?>>[];

  @override
  Future<void> submitReview({
    required String sessionId,
    required String tutorId,
    required int rating,
    required String comment,
    required String subject,
  }) async {
    calls.add({
      'sessionId': sessionId,
      'tutorId': tutorId,
      'rating': rating,
      'comment': comment,
      'subject': subject,
    });
  }
}

const _reviewArguments = {
  'sessionId': 'session-1',
  'tutorId': 'tutor-1',
  'subject': 'Kalkulus II',
};

void main() {
  late _SpyReviewController ctrl;

  setUp(() {
    Get.testMode = true;
    ctrl = _SpyReviewController();
    // Didaftarkan dengan tipe ReviewController supaya Get.find() di
    // ReviewScreen menemukan spy-nya; permanent agar tidak ikut dibersihkan
    // GetX saat navigasi antar test.
    Get.put<ReviewController>(ctrl, permanent: true);
  });

  tearDown(Get.reset);

  /// ReviewScreen dibuka seperti di aplikasi: lewat Get.to + arguments dari
  /// SessionController.endSession(). Route dashboard pengganti didaftarkan
  /// sebagai target tombol "Lewati"/"Kirim Ulasan".
  Future<void> pumpReviewScreen(
    WidgetTester tester, {
    Object? arguments = _reviewArguments,
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.customerDashboard,
        getPages: [
          GetPage(
            name: AppRoutes.customerDashboard,
            page: () => const Scaffold(body: Text('Dashboard Buddy')),
          ),
        ],
      ),
    );
    Get.to(() => const ReviewScreen(), arguments: arguments);
    await tester.pumpAndSettle();
  }

  /// Tombol di ReviewScreen bisa berada di bawah lipatan layar test, jadi
  /// selalu di-scroll dulu sebelum ditap.
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
  }

  group('ReviewScreen (widget)', () {
    testWidgets('tombol Kirim Ulasan baru aktif setelah bintang dipilih', (
      tester,
    ) async {
      await pumpReviewScreen(tester);

      // Bintang default 0 => tombol belum bisa ditekan.
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Kirim Ulasan'),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Kirim Ulasan'),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('Kirim Ulasan memakai tutorId & subject dari konteks sesi', (
      tester,
    ) async {
      await pumpReviewScreen(tester);

      await tester.tap(find.byIcon(Icons.star_border).at(4));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Tutor-nya sabar banget');
      await tapButton(tester, 'Kirim Ulasan');
      await tester.pump();

      expect(ctrl.calls, hasLength(1));
      expect(ctrl.calls.single['sessionId'], 'session-1');
      expect(ctrl.calls.single['tutorId'], 'tutor-1');
      expect(ctrl.calls.single['rating'], 5);
      expect(ctrl.calls.single['comment'], 'Tutor-nya sabar banget');
      expect(ctrl.calls.single['subject'], 'Kalkulus II');
    });

    testWidgets('Lewati tidak mengirim ulasan apa pun lalu keluar dari layar', (
      tester,
    ) async {
      await pumpReviewScreen(tester);

      await tapButton(tester, 'Lewati');
      await tester.pumpAndSettle();

      // W1-2: dulu "Lewati" menyimpan review 1 bintang palsu.
      expect(ctrl.calls, isEmpty);
      expect(find.byType(ReviewScreen), findsNothing);
      expect(find.text('Dashboard Buddy'), findsOneWidget);
    });

    testWidgets('tanpa konteks sesi/tutor, Lewati tetap bisa keluar', (
      tester,
    ) async {
      await pumpReviewScreen(tester, arguments: null);

      await tapButton(tester, 'Lewati');
      await tester.pumpAndSettle();

      expect(ctrl.calls, isEmpty);
      expect(find.text('Dashboard Buddy'), findsOneWidget);
    });

    testWidgets('tanpa konteks sesi/tutor, Kirim Ulasan menampilkan pesan', (
      tester,
    ) async {
      await pumpReviewScreen(tester, arguments: null);

      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();
      await tapButton(tester, 'Kirim Ulasan');
      await tester.pumpAndSettle();

      expect(find.text('Ulasan belum bisa dikirim'), findsOneWidget);
      expect(ctrl.calls, isEmpty);

      // Get.snackbar() punya Timer auto-dismiss — biarkan selesai penuh.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('ReviewController (logic)', () {
    test('menolak submit tanpa tutorId tanpa menyentuh data', () async {
      final controller = ReviewController();

      await controller.submitReview(
        sessionId: 'session-1',
        tutorId: '',
        rating: 5,
        comment: 'Bagus',
        subject: 'Kalkulus II',
      );

      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.isSubmitting.value, isFalse);
    });

    test('menolak submit tanpa sessionId tanpa menyentuh data', () async {
      final controller = ReviewController();

      await controller.submitReview(
        sessionId: '',
        tutorId: 'tutor-1',
        rating: 5,
        comment: 'Bagus',
        subject: 'Kalkulus II',
      );

      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.isSubmitting.value, isFalse);
    });

    test('konteks lengkap lolos guard dan mencoba menulis ulasan', () async {
      final controller = ReviewController();

      // Supabase belum diinisialisasi di unit test, jadi jalur tulis pasti
      // gagal di sini — yang diuji adalah guard-nya TIDAK mem-return lebih
      // awal (dulu jalur ini ikut terpanggil dengan tutorId kosong).
      await expectLater(
        controller.submitReview(
          sessionId: 'session-1',
          tutorId: 'tutor-1',
          rating: 4,
          comment: 'Enak diajak belajar',
          subject: 'Fisika Dasar',
        ),
        throwsA(anything),
      );

      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isSubmitting.value, isFalse);
    });
  });
}
