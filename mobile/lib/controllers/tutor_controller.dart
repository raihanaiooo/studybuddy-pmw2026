import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/tutor_model.dart';
import '../models/review_model.dart';

class TutorController extends GetxController {
  final RxList<TutorModel> tutors = <TutorModel>[].obs;
  final RxList<TutorModel> filtered = <TutorModel>[].obs;
  final Rx<TutorModel?> selectedTutor = Rx<TutorModel?>(null);
  final RxList<ReviewModel> tutorReviews = <ReviewModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  // Filter (FR-DISC-02, FR-DISC-03)
  final RxString filterJenjang = ''.obs;
  final RxString filterSubject = ''.obs;

  static const List<String> jenjangOptions = ['SMP', 'SMA', 'Mahasiswa'];

  final RxList<String> subjectOptions = <String>[].obs;

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

  /// Top 5 Tutor berdasarkan rating — untuk section "Rekomendasi"
  List<TutorModel> get topTutors => tutors.take(5).toList();

  Future<void> fetchAllTutors() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableTutors)
          .select()
          .eq('verification_status', 'verified')
          .order('rating', ascending: false);

      tutors.value = (data as List)
          .map((e) => TutorModel.fromMap(e as Map<String, dynamic>))
          .toList();
      _extractSubjectOptions();
      _applyFilter();
    } catch (e) {
      print('TutorController.fetchAllTutors error: $e');
      tutors.value = [];
      filtered.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _extractSubjectOptions() {
    final set = <String>{};
    for (final t in tutors) {
      set.addAll(t.subjects);
    }
    final sorted = set.toList()..sort();
    subjectOptions.value = sorted;
  }

  void _applyFilter() {
    final q = searchQuery.value.toLowerCase().trim();
    final jenjang = filterJenjang.value;
    final subject = filterSubject.value;

    filtered.value = tutors.where((t) {
      if (q.isNotEmpty) {
        final matchName = t.fullName.toLowerCase().contains(q);
        final matchSubject = t.subjects.any((s) => s.toLowerCase().contains(q));
        if (!matchName && !matchSubject) return false;
      }

      if (jenjang.isNotEmpty && !t.jenjangDiajar.contains(jenjang)) {
        return false;
      }

      if (subject.isNotEmpty && !t.subjects.contains(subject)) {
        return false;
      }

      return true;
    }).toList();
  }

  void setFilterJenjang(String jenjang) {
    filterJenjang.value = jenjang;
    _applyFilter();
  }

  void setFilterSubject(String subject) {
    filterSubject.value = subject;
    _applyFilter();
  }

  void resetFilters() {
    filterJenjang.value = '';
    filterSubject.value = '';
    searchQuery.value = '';
    _applyFilter();
  }

  bool get hasActiveFilter =>
      filterJenjang.value.isNotEmpty || filterSubject.value.isNotEmpty;

  Future<void> selectTutor(TutorModel tutor) async {
    selectedTutor.value = tutor;
    await _fetchReviews(tutor.id);
  }

  Future<void> _fetchReviews(String tutorId) async {
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableReviews)
          .select()
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false)
          .limit(10);

      tutorReviews.value = (data as List)
          .map((e) => ReviewModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('TutorController._fetchReviews error: $e');
      tutorReviews.value = [];
    }
  }
}
