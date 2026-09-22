import 'dart:async';
import 'package:get/get.dart';
import '../models/invoice_model.dart';

/// Controller invoice & status pembayaran (FR-PAY-01..14)
///
/// Masih dummy data (contract-first) — tinggal ganti generateInvoice()
/// dengan insert ke tabel Invoice, dan checkPaymentStatus() dengan
/// polling status webhook ShopeePay Merchant begitu kontrak BE modul
/// Pembayaran tersedia.
class PaymentController extends GetxController {
  Timer? _countdownTimer;

  final Rx<InvoiceModel?> invoice = Rx<InvoiceModel?>(null);
  final RxInt remainingSeconds = 0.obs;
  final RxBool isCheckingStatus = false.obs;

  final RxList<InvoiceModel> history = <InvoiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// Buat invoice baru untuk booking (FR-PAY-01), timer kedaluwarsa 15
  /// menit pasti sejak diterbitkan (FR-PAY-06)
  void generateInvoice({
    required String tutorName,
    required String studentName,
    required String studentGrade,
    required String studentSchool,
    required List<InvoiceSessionItem> sessions,
    double discount = 0,
  }) {
    final now = DateTime.now();
    final id =
        'INV/SB/${_formatYmd(now)}/${now.millisecondsSinceEpoch.toString().substring(7)}';

    invoice.value = InvoiceModel(
      id: id,
      bookingId: 'booking-${now.millisecondsSinceEpoch}',
      studentName: studentName,
      studentGrade: studentGrade,
      studentSchool: studentSchool,
      tutorName: tutorName,
      sessions: sessions,
      discount: discount,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _tickRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickRemaining();
    });
  }

  void _tickRemaining() {
    final inv = invoice.value;
    if (inv == null) return;
    final diff = inv.expiresAt.difference(DateTime.now()).inSeconds;
    remainingSeconds.value = diff > 0 ? diff : 0;
    if (diff <= 0 && inv.status == InvoiceStatus.waiting) {
      invoice.value = inv.copyWith(status: InvoiceStatus.expired);
      _countdownTimer?.cancel();
    }
  }

  String get remainingLabel {
    final m = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Cek status pembayaran (polling webhook payment gateway — FR-PAY-07)
  ///
  /// TODO: ganti dengan polling status asli dari webhook ShopeePay begitu
  /// backend siap. Untuk demo UI tanpa gateway sungguhan, tap ini
  /// langsung menandai invoice Lunas.
  Future<void> checkPaymentStatus() async {
    final inv = invoice.value;
    if (inv == null || inv.status != InvoiceStatus.waiting) return;

    isCheckingStatus.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    invoice.value = inv.copyWith(status: InvoiceStatus.paid, paidAt: DateTime.now());
    _countdownTimer?.cancel();
    history.insert(0, invoice.value!);
    isCheckingStatus.value = false;

    Get.snackbar('Lunas', 'Pembayaran berhasil, link Google Meet sudah terpasang');
  }

  /// Batalkan pesanan sebelum bayar — otomatis membuka kembali slot
  /// jadwal Tutor (FR-PAY-07)
  void cancelOrder() {
    final inv = invoice.value;
    if (inv == null) return;
    invoice.value = inv.copyWith(status: InvoiceStatus.cancelled);
    _countdownTimer?.cancel();
    Get.back();
    Get.snackbar('Dibatalkan', 'Pesanan dibatalkan, slot jadwal dibuka kembali');
  }

  /// Ajukan refund pasca-bayar (FR-PAY-09/10) — alur kategori refund per
  /// jenis paket menyusul begitu modul Paket & Token terintegrasi.
  void requestRefund(String invoiceId, String reason) {
    Get.back();
    Get.snackbar(
      'Diajukan',
      'Permintaan refund kamu sedang diproses tim Finance',
    );
  }

  Future<void> fetchHistory() async {
    // Defensive copy — _dummyHistory itu `static final` dipakai bareng
    // semua instance, jangan sampai kemutasi lewat history.insert().
    history.value = List<InvoiceModel>.from(_dummyHistory);
  }

  String _formatYmd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  static final List<InvoiceModel> _dummyHistory = [
    InvoiceModel(
      id: 'INV/SB/20260910/48213',
      bookingId: 'booking-1',
      studentName: 'Sari Amalia',
      studentGrade: 'Mahasiswa (S1)',
      studentSchool: 'Politeknik Negeri Bandung',
      tutorName: 'Arif Rahmat',
      sessions: [
        InvoiceSessionItem(
          subject: 'Kalkulus II',
          sessionDate: DateTime(2026, 9, 10),
          startTime: '09:00',
          endTime: '10:00',
          price: 50000,
        ),
      ],
      status: InvoiceStatus.paid,
      createdAt: DateTime(2026, 9, 10, 8, 40),
      expiresAt: DateTime(2026, 9, 10, 8, 55),
      paidAt: DateTime(2026, 9, 10, 8, 47),
    ),
    InvoiceModel(
      id: 'INV/SB/20260905/10029',
      bookingId: 'booking-2',
      studentName: 'Sari Amalia',
      studentGrade: 'Mahasiswa (S1)',
      studentSchool: 'Politeknik Negeri Bandung',
      tutorName: 'Nurul Hidayah',
      sessions: [
        InvoiceSessionItem(
          subject: 'Fisika Dasar',
          sessionDate: DateTime(2026, 9, 5),
          startTime: '13:00',
          endTime: '14:00',
          price: 45000,
        ),
      ],
      status: InvoiceStatus.expired,
      createdAt: DateTime(2026, 9, 5, 12, 30),
      expiresAt: DateTime(2026, 9, 5, 12, 45),
    ),
  ];
}
