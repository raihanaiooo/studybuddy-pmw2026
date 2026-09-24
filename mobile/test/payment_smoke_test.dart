import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/payment_controller.dart';
import 'package:studybuddy/models/invoice_model.dart';
import 'package:studybuddy/views/customer/invoice_screen.dart';
import 'package:studybuddy/views/customer/transaction_history_screen.dart';

void main() {
  setUpAll(() async {
    // AppDateUtils pakai DateFormat(..., 'id'), butuh ini diinisialisasi
    // sekali sebelum test jalan.
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  PaymentController seedInvoice() {
    final ctrl = Get.put(PaymentController());
    ctrl.generateInvoice(
      tutorName: 'Arif Rahmat',
      studentName: 'Sari Amalia',
      studentGrade: 'Mahasiswa (S1)',
      studentSchool: 'Politeknik Negeri Bandung',
      sessions: [
        InvoiceSessionItem(
          subject: 'Kalkulus II',
          sessionDate: DateTime.now().add(const Duration(days: 1)),
          startTime: '09:00',
          endTime: '10:00',
          price: 50000,
        ),
      ],
    );
    return ctrl;
  }

  testWidgets('InvoiceScreen menampilkan detail & QR saat menunggu bayar', (
    tester,
  ) async {
    final ctrl = seedInvoice();
    await tester.pumpWidget(const GetMaterialApp(home: InvoiceScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('INV/SB/'), findsOneWidget);
    expect(find.text('Menunggu Pembayaran'), findsOneWidget);
    expect(find.text('Kalkulus II'), findsOneWidget);
    expect(find.text('Rp50.000'), findsWidgets);
    expect(find.text('Cek Status Pembayaran'), findsOneWidget);

    // Countdown pakai Timer.periodic — cancel eksplisit di sini karena
    // widget test tidak melalui siklus hidup route GetX yang biasanya
    // memicu onClose() otomatis.
    ctrl.onClose();
  });

  testWidgets('Cek Status Pembayaran menandai invoice Lunas', (tester) async {
    final ctrl = seedInvoice();
    await tester.pumpWidget(const GetMaterialApp(home: InvoiceScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cek Status Pembayaran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
    ctrl.onClose(); // sudah di-cancel di checkPaymentStatus(), jaga-jaga

    // checkPaymentStatus() juga memicu Get.snackbar() — biarkan Timer
    // auto-dismiss-nya selesai penuh sebelum test berakhir.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('Batalkan Pesanan mengubah status jadi Dibatalkan', (
    tester,
  ) async {
    final ctrl = seedInvoice();
    await tester.pumpWidget(const GetMaterialApp(home: InvoiceScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Batalkan Pesanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batalkan Pesanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya, Batalkan'));
    await tester.pump();

    expect(ctrl.invoice.value?.status, InvoiceStatus.cancelled);
    ctrl.onClose(); // sudah di-cancel di cancelOrder(), jaga-jaga

    // cancelOrder() juga memicu Get.snackbar() — biarkan Timer
    // auto-dismiss-nya selesai penuh sebelum test berakhir.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('TransactionHistoryScreen menampilkan riwayat & tombol refund', (
    tester,
  ) async {
    Get.put(PaymentController());
    await tester.pumpWidget(
      const GetMaterialApp(home: TransactionHistoryScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kalkulus II'), findsOneWidget);
    expect(find.text('Ajukan Refund'), findsOneWidget);

    await tester.tap(find.text('Ajukan Refund'));
    await tester.pumpAndSettle();

    expect(find.text('Alasan Pembatalan'), findsOneWidget);
    expect(find.text('Jadwal bentrok'), findsOneWidget);
  });

  testWidgets(
    'cancelOrder() saat checkPaymentStatus() masih menunggu tidak '
    'ke-overwrite balik jadi Lunas',
    (tester) async {
      // cancelOrder() memanggil Get.snackbar(), yang butuh overlay dari
      // widget tree GetMaterialApp sungguhan (tidak jalan di test() polos).
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      final ctrl = Get.put(PaymentController());
      ctrl.generateInvoice(
        tutorName: 'Arif Rahmat',
        studentName: 'Sari Amalia',
        studentGrade: 'Mahasiswa (S1)',
        studentSchool: 'Politeknik Negeri Bandung',
        sessions: [
          InvoiceSessionItem(
            subject: 'Kalkulus II',
            sessionDate: DateTime.now().add(const Duration(days: 1)),
            startTime: '09:00',
            endTime: '10:00',
            price: 50000,
          ),
        ],
      );

      // Mulai cek status (delay 600ms, jalan di fake clock testWidgets),
      // tapi batalkan pesanan SEBELUM delay itu selesai — meniru user
      // yang keburu tap Batalkan sebelum "Cek Status" kelar diproses.
      ctrl.checkPaymentStatus();
      await tester.pump(const Duration(milliseconds: 50));
      ctrl.cancelOrder();
      // Majukan waktu sampai delay 600ms di checkPaymentStatus() kelar.
      await tester.pump(const Duration(milliseconds: 700));

      expect(ctrl.invoice.value?.status, InvoiceStatus.cancelled);
      ctrl.onClose();

      // cancelOrder() & checkPaymentStatus() sama-sama memicu
      // Get.snackbar() — biarkan Timer auto-dismiss-nya selesai penuh.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    },
  );
}
