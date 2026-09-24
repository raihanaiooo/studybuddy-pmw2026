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

  // Filter aktif (FR-DISC-02, FR-DISC-03)
  final RxString filterJenjang = ''.obs; // '' = semua
  final RxString filterSubject = ''.obs; // '' = semua

  /// Daftar jenjang yang tersedia (hardcode sesuai SRS FR-DISC-03)
  static const List<String> jenjangOptions = ['SMP', 'SMA', 'Mahasiswa'];

  /// Daftar mapel unik dari data tutor (untuk chip filter)
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

  /// Ambil daftar mapel unik dari semua tutor
  void _extractSubjectOptions() {
    final set = <String>{};
    for (final t in tutors) {
      set.addAll(t.subjects);
    }
    final sorted = set.toList()..sort();
    subjectOptions.value = sorted;
  }

  /// Terapkan semua filter: search query + jenjang + mapel
  void _applyFilter() {
    final q = searchQuery.value.toLowerCase().trim();
    final jenjang = filterJenjang.value;
    final subject = filterSubject.value;

    filtered.value = tutors.where((t) {
      // Filter search query
      if (q.isNotEmpty) {
        final matchName = t.fullName.toLowerCase().contains(q);
        final matchSubject = t.subjects.any((s) => s.toLowerCase().contains(q));
        if (!matchName && !matchSubject) return false;
      }

      // Filter jenjang (FR-DISC-03)
      if (jenjang.isNotEmpty && !t.jenjangDiajar.contains(jenjang)) {
        return false;
      }

      // Filter mapel (FR-DISC-02)
      if (subject.isNotEmpty && !t.subjects.contains(subject)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Set filter jenjang
  void setFilterJenjang(String jenjang) {
    filterJenjang.value = jenjang;
    _applyFilter();
  }

  /// Set filter mapel
  void setFilterSubject(String subject) {
    filterSubject.value = subject;
    _applyFilter();
  }

  /// Reset semua filter
  void resetFilters() {
    filterJenjang.value = '';
    filterSubject.value = '';
    searchQuery.value = '';
    _applyFilter();
  }

  /// Apakah ada filter aktif?
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
