import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import 'auth_controller.dart';

/// Controller dashboard Tutor: status online, statistik ringkas, & link
/// Google Meet permanen (FR-SESI-02)
///
/// Statistik & link GMeet masih dummy mengikuti alur contract-first —
/// tinggal ganti dengan query Supabase begitu kontrak BE untuk modul ini
/// (dan Payroll di 3.9) tersedia.
class TutorDashboardController extends GetxController {
  final _authService = AuthService();

  final RxBool isOnline = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  // Statistik ringkas (dummy)
  final RxDouble avgRating = 4.8.obs;
  final RxInt sessionsToday = 2.obs;
  final RxDouble monthlyEarnings = 1250000.0.obs;

  // FR-SESI-02: setiap Tutor difasilitasi minimal 3 link GMeet permanen
  final RxList<String> gmeetLinks = <String>[
    'meet.google.com/arif-fis-xyz',
    'meet.google.com/arif-mat-abc',
    'meet.google.com/arif-kim-def',
  ].obs;

  /// Toggle status online — dipakai Buddy untuk menemukan Tutor di
  /// Smart Discovery (FR-DISC-05)
  Future<void> toggleOnline(bool value, AuthController auth) async {
    final userId = auth.currentUser.value?.id;
    if (userId == null) return;

    isUpdatingStatus.value = true;
    try {
      await _authService.updateOnlineStatus(tutorId: userId, isOnline: value);
      isOnline.value = value;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  void updateGmeetLink(int index, String newLink) {
    if (index < 0 || index >= gmeetLinks.length || newLink.trim().isEmpty) {
      return;
    }
    gmeetLinks[index] = newLink.trim();
    Get.snackbar('Berhasil', 'Link GMeet #${index + 1} diperbarui');
  }
}
