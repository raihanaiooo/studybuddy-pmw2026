import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import 'auth_controller.dart';

/// Controller dashboard Tutor: status online & statistik ringkas
class TutorDashboardController extends GetxController {
  final _authService = AuthService();

  final RxBool isOnline = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  // Statistik ringkas (dummy — nanti diisi dari DB)
  final RxDouble avgRating = 0.0.obs;
  final RxInt sessionsToday = 0.obs;
  final RxDouble monthlyEarnings = 0.0.obs;

  /// Toggle status online — dipakai Buddy untuk menemukan Tutor di
  /// Smart Discovery (FR-DISC-05)
  Future<void> toggleOnline(bool value, AuthController auth) async {
    final userId = auth.currentUser.value?.id;
    if (userId == null) return;

    isUpdatingStatus.value = true;
    try {
      await _authService.updateOnlineStatus(tutorId: userId, isOnline: value);
      isOnline.value = value;
    } catch (_) {
      Get.snackbar('Gagal', 'Tidak bisa mengubah status online, coba lagi');
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}
