import 'package:get/get.dart';
import '../models/payroll_model.dart';

/// Controller Payroll/Honor Tutor (FR-PAYR-01..07)
///
/// Masih dummy data (contract-first) — tinggal ganti fetchRecords()
/// dengan query tabel PayrollRecord begitu kontrak BE modul Payroll
/// tersedia. Rekap otomatis (FR-PAYR-06) & reminder Finance (FR-PAYR-04)
/// serta approval pembayaran (FR-PAYR-05) adalah tanggung jawab BE/Web
/// Panel Manajemen — sisi Tutor di sini hanya menampilkan hasilnya.
class PayrollController extends GetxController {
  final RxList<PayrollRecordModel> records = <PayrollRecordModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    isLoading.value = true;
    records.value = List<PayrollRecordModel>.from(_dummyRecords);
    isLoading.value = false;
  }

  /// Saldo "Belum Dibayar" berjalan (FR-PAYR-01/03) — dijumlah dari
  /// semua periode yang statusnya belum dibayar.
  double get pendingBalance => records
      .where((r) => r.status == PayrollStatus.belumDibayar)
      .fold(0, (sum, r) => sum + r.remainingBalance);

  List<PayrollRecordModel> get paidHistory =>
      records.where((r) => r.status == PayrollStatus.sudahDibayar).toList();

  static final List<PayrollRecordModel> _dummyRecords = [
    PayrollRecordModel(
      id: 'payroll-2026-09',
      tutorId: 'tutor-me',
      tutorName: 'Arif Rahmat',
      period: 'September 2026',
      status: PayrollStatus.belumDibayar,
      sessions: [
        SessionEarningItem(
          classDate: DateTime(2026, 9, 3),
          buddyName: 'Sari Amalia',
          material: 'Kalkulus II — Turunan',
          ratePerSession: 35000,
        ),
        SessionEarningItem(
          classDate: DateTime(2026, 9, 8),
          buddyName: 'Farhan Malik',
          material: 'Fisika Dasar — Kinematika',
          ratePerSession: 35000,
        ),
        SessionEarningItem(
          classDate: DateTime(2026, 9, 15),
          buddyName: 'Sari Amalia',
          material: 'Kalkulus II — Integral',
          ratePerSession: 35000,
          deduction: 10000,
          deductionNote: 'Terlambat masuk kelas >15 menit',
        ),
      ],
    ),
    PayrollRecordModel(
      id: 'payroll-2026-08',
      tutorId: 'tutor-me',
      tutorName: 'Arif Rahmat',
      period: 'Agustus 2026',
      status: PayrollStatus.sudahDibayar,
      totalTransferred: 245000,
      transferDate: DateTime(2026, 8, 31),
      sessions: [
        SessionEarningItem(
          classDate: DateTime(2026, 8, 5),
          buddyName: 'Nurul Hidayah',
          material: 'Aljabar Linear',
          sessionCount: 3,
          ratePerSession: 35000,
        ),
        SessionEarningItem(
          classDate: DateTime(2026, 8, 20),
          buddyName: 'Rania Putri',
          material: 'Kalkulus II',
          sessionCount: 4,
          ratePerSession: 35000,
        ),
      ],
    ),
  ];
}
