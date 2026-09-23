import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/review_model.dart';
import '../app/routes.dart';

/// Controller untuk submit dan tampilkan rating & ulasan
class ReviewController extends GetxController {
  final _authService = AuthService();

  final RxInt selectedRating = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  /// Submit ulasan setelah sesi selesai
  Future<void> submitReview({
    required String sessionId,
    required String tutorId,
    required int rating,
    required String comment,
    required String subject,
  }) async {
    // Ulasan tanpa konteks sesi/tutor tidak boleh ditulis: record seperti itu
    // tidak bisa diatribusikan ke Tutor mana pun (W1-1).
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

      // Update rata-rata rating tutor
      await _recalculateTutorRating(tutorId);

      Get.offAllNamed(AppRoutes.customerDashboard);
      Get.snackbar('Terima kasih!', 'Ulasan kamu sudah tersimpan.');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Hitung ulang rating rata-rata tutor dari semua ulasan
  Future<void> _recalculateTutorRating(String tutorId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableReviews)
        .select('rating')
        .eq('tutor_id', tutorId);

    if ((data as List).isEmpty) return;

    final avg =
        data.map((e) => e['rating'] as int).reduce((a, b) => a + b) /
        data.length;

    await SupabaseService.client
        .from(SupabaseConstants.tableTutors)
        .update({
          'rating': double.parse(avg.toStringAsFixed(1)),
          'total_reviews': data.length,
        })
        .eq('id', tutorId);
  }
}
