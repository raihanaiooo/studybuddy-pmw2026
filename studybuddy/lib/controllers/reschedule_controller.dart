import 'package:get/get.dart';
import '../models/reschedule_model.dart';

/// Controller pengajuan reschedule sesi (FR-RESCH-01..09)
///
/// Aturan bisnis (dari client):
/// - Threshold: maksimal H-5 jam sebelum sesi
/// - Max postpone: 2 hari dari jadwal semula
/// - Max reschedule: 5x (khusus paket bulanan)
/// - Wajib approval admin, tidak langsung disetujui
///
/// Masih dummy data — tinggal ganti fetch/submit dengan query tabel
/// `reschedules` begitu migrasi DB dilakukan.
class RescheduleController extends GetxController {
  static const thresholdHours = 5;
  static const maxPostponeDays = 2;
  static const maxRescheduleCount = 5;

  final RxList<RescheduleModel> myRequests = <RescheduleModel>[].obs;
  final RxInt quotaLeft = maxRescheduleCount.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyRequests();
  }

  Future<void> fetchMyRequests() async {
    myRequests.value = List<RescheduleModel>.from(_dummyRequests);
  }

  /// Ajukan reschedule. Mengembalikan null kalau validasi gagal (lihat
  /// errorMessage), atau RescheduleModel hasil pengajuan.
  ///
  /// Semua pengajuan sekarang masuk `menungguAdmin` — client bilang
  /// harus persetujuan dulu, tidak langsung.
  RescheduleModel? submitReschedule({
    required String bookingId,
    required DateTime originalSessionTime,
    required DateTime newSessionTime,
    required String reason,
    bool switchTutor = false,
  }) {
    errorMessage.value = '';

    if (reason.trim().isEmpty) {
      errorMessage.value = 'Alasan reschedule wajib diisi';
      return null;
    }

    // Cek kuota (max 5x)
    if (quotaLeft.value <= 0) {
      errorMessage.value =
          'Kuota reschedule sudah habis (maksimal $maxRescheduleCount kali).';
      return null;
    }

    // Cek threshold H-5
    final hoursUntilSession = originalSessionTime
        .difference(DateTime.now())
        .inHours;
    if (hoursUntilSession < thresholdHours) {
      errorMessage.value =
          'Reschedule maksimal H-$thresholdHours jam sebelum sesi dimulai.';
      return null;
    }

    // Cek max postpone 2 hari
    final maxAllowed = originalSessionTime.add(
      const Duration(days: maxPostponeDays),
    );
    if (newSessionTime.isAfter(maxAllowed)) {
      errorMessage.value =
          'Jadwal baru maksimal $maxPostponeDays hari dari jadwal semula';
      return null;
    }
    if (!newSessionTime.isAfter(DateTime.now())) {
      errorMessage.value = 'Jadwal baru harus di masa depan';
      return null;
    }

    // Semua pengajuan butuh approval admin (client: "harus persetujuan dulu")
    final adminNote = switchTutor
        ? 'Pengalihan ke Tutor lain perlu persetujuan Admin'
        : 'Pengajuan reschedule perlu persetujuan Admin';

    final request = RescheduleModel(
      id: 'resch-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      reason: reason,
      originalSessionTime: originalSessionTime,
      newSessionTime: newSessionTime,
      status: RescheduleStatus.menungguAdmin,
      requestedBy: 'buddy',
      adminNote: adminNote,
      createdAt: DateTime.now(),
    );

    myRequests.insert(0, request);
    quotaLeft.value--;

    return request;
  }

  static final List<RescheduleModel> _dummyRequests = [
    RescheduleModel(
      id: 'resch-past-1',
      bookingId: 'booking-past-1',
      reason: 'Ada ujian mendadak',
      originalSessionTime: DateTime.now().subtract(const Duration(days: 3)),
      newSessionTime: DateTime.now().subtract(const Duration(days: 2)),
      status: RescheduleStatus.disetujui,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
