import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/tutor_model.dart';
import '../models/review_model.dart';

/// Controller untuk discovery & detail tutor
class TutorController extends GetxController {
  final RxList<TutorModel> tutors = <TutorModel>[].obs;
  final RxList<TutorModel> filtered = <TutorModel>[].obs;
  final Rx<TutorModel?> selectedTutor = Rx<TutorModel?>(null);
  final RxList<ReviewModel> tutorReviews = <ReviewModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTutors();
    debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
  }

  /// Fetch semua tutor aktif dari database
  Future<void> fetchAllTutors() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableTutors)
          .select()
          .order('rating', ascending: false);

      tutors.value = (data as List)
          .map((e) => TutorModel.fromMap(e as Map<String, dynamic>))
          .toList();
      filtered.value = tutors;
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter tutor berdasarkan nama atau mata kuliah
  void _applyFilter() {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) {
      filtered.value = tutors;
      return;
    }
    filtered.value = tutors.where((t) {
      return t.fullName.toLowerCase().contains(q) ||
          t.subjects.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  /// Pilih tutor dan load ulasannya
  Future<void> selectTutor(TutorModel tutor) async {
    selectedTutor.value = tutor;
    await _fetchReviews(tutor.id);
  }

  /// Fetch ulasan untuk tutor tertentu
  Future<void> _fetchReviews(String tutorId) async {
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableReviews)
        .select()
        .eq('tutor_id', tutorId)
        .order('created_at', ascending: false)
        .limit(10);

    tutorReviews.value = (data as List)
        .map((e) => ReviewModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Rekomendasi tutor berdasarkan kuesioner (subject match)
  List<TutorModel> getRecommendations(String subject) {
    return tutors
        .where(
          (t) => t.subjects.any(
            (s) => s.toLowerCase().contains(subject.toLowerCase()),
          ),
        )
        .toList();
  }
}
