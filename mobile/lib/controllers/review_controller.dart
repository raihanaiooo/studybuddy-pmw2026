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

      // Cek apakah sudah pernah review session ini
      final existing = await SupabaseService.client
          .from(SupabaseConstants.tableReviews)
          .select('id')
          .eq('session_id', sessionId)
          .eq('customer_id', user.id)
          .maybeSingle();

      if (existing != null) {
        errorMessage.value = 'Kamu sudah pernah memberi ulasan untuk sesi ini.';
        Get.snackbar('Info', errorMessage.value);
        Get.offAllNamed(AppRoutes.customerDashboard);
        return;
      }

      await SupabaseService.client.from(SupabaseConstants.tableReviews).insert({
        'session_id': sessionId,
        'customer_id': user.id,
        'tutor_id': tutorId,
        'rating': rating,
        'comment': comment,
        'subject': subject,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.offAllNamed(AppRoutes.customerDashboard);
      Get.snackbar('Terima kasih!', 'Ulasan kamu sudah tersimpan.');
    } catch (e) {
      print('ReviewController.submitReview error: $e');
      // Handle unique constraint violation
      if (e.toString().contains('uq_reviews_session')) {
        errorMessage.value = 'Kamu sudah pernah memberi ulasan untuk sesi ini.';
        Get.snackbar('Info', errorMessage.value);
        Get.offAllNamed(AppRoutes.customerDashboard);
        return;
      }
      errorMessage.value = 'Gagal mengirim ulasan. Coba lagi.';
      Get.snackbar('Gagal', 'Ulasan tidak tersimpan. Coba lagi.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
