import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/booking_controller.dart';

/// Test keamanan realtime booking (Wave 2.2) TANPA Supabase.
///
/// Supabase sengaja TIDAK diinisialisasi di sini: widget test tidak boleh
/// menyentuh jaringan, dan justru itu yang diuji — langganan realtime
/// tidak boleh mengklaim sukses palsu (realtimeSubscribed tetap false),
/// onInit tetap selesai, dan daftar booking kosong tanpa spinner
/// tergantung.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets(
    'BookingController tanpa Supabase: tidak ada sukses palsu langganan realtime',
    (tester) async {
      BookingController? ctrl;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              // Dipasang di dalam build agar onInit berjalan saat pump.
              ctrl = Get.put(BookingController());
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(); // onInit + fetchMyBookings + upaya langganan.
      await tester.pump(const Duration(seconds: 1));

      expect(ctrl, isNotNull);
      expect(ctrl!.realtimeSubscribed, isFalse); // Tidak ada sukses palsu.
      expect(ctrl!.isLoading.value, isFalse); // Fetch gagal tidak menggantung.
      expect(ctrl!.myBookings, isEmpty);
      expect(ctrl!.tutorBookings, isEmpty);

      // onClose dipanggil oleh Get.reset lewat tearDown; klon pemakaian
      // kembali juga harus aman (tidak melempar).
      await Get.delete<BookingController>();
      await tester.pump();
    },
  );

  testWidgets(
    'BookingController dipakai ulang (re-init) setelah onClose tetap aman tanpa Supabase',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(BookingController());
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      await Get.delete<BookingController>();
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              Get.put(BookingController());
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final ctrl = Get.find<BookingController>();
      expect(ctrl.realtimeSubscribed, isFalse);
      expect(ctrl.isLoading.value, isFalse);
    },
  );
}
