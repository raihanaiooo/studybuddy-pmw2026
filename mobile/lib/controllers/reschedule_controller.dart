import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../data/reschedule_repository_supabase.dart';
import '../domain/reschedule_repository.dart';
import '../models/reschedule_model.dart';

class RescheduleController extends GetxController {
  RescheduleController({RescheduleRepository? repository})
    : _repo = repository ?? RescheduleRepositorySupabase();

  final RescheduleRepository _repo;
  final _authService = AuthService();

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
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      myRequests.value = await _repo.fetchMyRequests(user.id);
      // Hitung kuota: max - jumlah yang sudah dipakai
      final used = await _repo.countMyRequestsThisMonth(user.id);
      quotaLeft.value = (maxRescheduleCount - used).clamp(
        0,
        maxRescheduleCount,
      );
    } catch (e) {
      print('RescheduleController.fetchMyRequests error: $e');
      errorMessage.value = 'Gagal memuat riwayat reschedule.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Ajukan reschedule. Mengembalikan null kalau validasi gagal
  /// (lihat errorMessage), atau RescheduleModel hasil pengajuan.
  Future<RescheduleModel?> submitReschedule({
    required String bookingId,
    required DateTime originalSessionTime,
    required DateTime newSessionTime,
    required String reason,
    bool switchTutor = false,
  }) async {
    errorMessage.value = '';

    if (reason.trim().isEmpty) {
      errorMessage.value = 'Alasan reschedule wajib diisi';
      return null;
    }

    if (quotaLeft.value <= 0) {
      errorMessage.value =
          'Kuota reschedule sudah habis (maksimal $maxRescheduleCount kali).';
      return null;
    }

    final hoursUntilSession = originalSessionTime
        .difference(DateTime.now())
        .inHours;
    if (hoursUntilSession < thresholdHours) {
      errorMessage.value =
          'Reschedule maksimal H-$thresholdHours jam sebelum sesi dimulai.';
      return null;
    }

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

    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return null;

      final request = await _repo.submitRequest(
        bookingId: bookingId,
        requestedBy: user.id,
        requestedByRole: 'buddy',
        reason: reason,
        originalSessionTime: originalSessionTime,
        newSessionTime: newSessionTime,
      );

      myRequests.insert(0, request);
      quotaLeft.value = (quotaLeft.value - 1).clamp(0, maxRescheduleCount);

      return request;
    } catch (e) {
      print('RescheduleController.submitReschedule error: $e');
      errorMessage.value = 'Gagal mengirim pengajuan. Coba lagi.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
