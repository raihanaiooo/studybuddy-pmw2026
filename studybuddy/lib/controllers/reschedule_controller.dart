import 'package:get/get.dart';
import '../models/reschedule_model.dart';

/// Controller pengajuan reschedule sesi (FR-RESCH-01..09)
///
/// Masih dummy data (contract-first) — tinggal ganti fetch/submit dengan
/// query tabel Reschedule begitu kontrak BE tersedia. Kuota reschedule
/// (quotaLeft) idealnya datang dari Paket & Token milik Buddy (3.4);
/// untuk sekarang dipakai nilai dummy karena modul itu di branch
/// terpisah (ui/paket-token) yang belum di-merge.
class RescheduleController extends GetxController {
  static const thresholdHours = 6;
  static const maxPostponeDays = 2;

  final RxList<RescheduleModel> myRequests = <RescheduleModel>[].obs;
  final RxInt quotaLeft = 3.obs;
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

  /// Kondisi FR-RESCH-06: kuota habis, pengajuan <6 jam sebelum sesi, atau
  /// pengalihan ke Tutor lain — butuh approval manual Admin. Di luar itu,
  /// diproses otomatis.
  bool needsAdminApproval({
    required DateTime originalSessionTime,
    bool switchTutor = false,
  }) {
    final hoursUntilSession = originalSessionTime.difference(DateTime.now()).inHours;
    return switchTutor || hoursUntilSession < thresholdHours || quotaLeft.value <= 0;
  }

  String? _adminApprovalReason({
    required DateTime originalSessionTime,
    required bool switchTutor,
  }) {
    if (switchTutor) return 'Pengalihan ke Tutor lain perlu persetujuan Admin';
    final hoursUntilSession = originalSessionTime.difference(DateTime.now()).inHours;
    if (hoursUntilSession < thresholdHours) {
      return 'Pengajuan di bawah H-6 jam sebelum sesi perlu persetujuan Admin';
    }
    if (quotaLeft.value <= 0) {
      return 'Kuota reschedule paket sudah habis, perlu persetujuan Admin';
    }
    return null;
  }

  /// Ajukan reschedule. Mengembalikan null kalau validasi gagal (lihat
  /// errorMessage), atau RescheduleModel hasil pengajuan.
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

    // FR-RESCH-05: batas maksimal pengunduran 2 hari dari jadwal semula
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

    final adminReason = _adminApprovalReason(
      originalSessionTime: originalSessionTime,
      switchTutor: switchTutor,
    );

    final request = RescheduleModel(
      id: 'resch-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      reason: reason,
      originalSessionTime: originalSessionTime,
      newSessionTime: newSessionTime,
      status: adminReason != null
          ? RescheduleStatus.menungguAdmin
          : RescheduleStatus.disetujui,
      adminNote: adminReason,
      createdAt: DateTime.now(),
    );

    myRequests.insert(0, request);
    if (quotaLeft.value > 0) quotaLeft.value--;

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
