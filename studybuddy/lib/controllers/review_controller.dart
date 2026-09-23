import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/supabase_constants.dart';
import '../app/routes.dart';

class ReviewController extends GetxController {
  final _authService = AuthService();

  final RxInt selectedRating = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> submitReview({
    required String sessionId,
    required String tutorId,
    required int rating,
    required String comment,
    required String subject,
  }) async {
    if (sessionId.isEmpty || tutorId.isEmpty) {
      errorMessage.value =
          'Konteks sesi/tutor tidak tersedia, ulasan tidak dikirim.';
      return;
    }

    errorMessage.value = '';
    isSubmitting.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      await SupabaseService.client.from(SupabaseConstants.tableReviews).insert({
        'session_id': sessionId,
        'customer_id': user.id,
        'tutor_id': tutorId,
        'rating': rating,
        'comment': comment,
        'subject': subject,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Rating aggregate di-handle oleh trigger di DB
      // (trg_reviews_update_tutor_stats) — tidak perlu client-side update.

      Get.offAllNamed(AppRoutes.customerDashboard);
      Get.snackbar('Terima kasih!', 'Ulasan kamu sudah tersimpan.');
    } catch (e) {
      print('ReviewController.submitReview error: $e');
      errorMessage.value = 'Gagal mengirim ulasan. Coba lagi.';
      Get.snackbar('Gagal', 'Ulasan tidak tersimpan. Coba lagi.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
