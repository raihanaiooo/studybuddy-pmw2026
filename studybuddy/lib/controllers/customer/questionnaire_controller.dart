import 'package:get/get.dart';
import '../../models/tutor_model.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/prototype.dart';
import '../../app/routes.dart';

/// Controller untuk kuesioner rekomendasi tutor
class QuestionnaireController extends GetxController {
  final RxString selectedSubject = ''.obs;
  final RxString selectedGoal = ''.obs;
  final RxString selectedLevel = ''.obs;
  final RxList<TutorModel> recommendedTutors = <TutorModel>[].obs;
  final RxBool hasSubmitted = false.obs;

  final List<String> subjects = [
    'Matematika',
    'Fisika',
    'Kimia',
    'Statistika',
    'Pemrograman',
    'Akuntansi',
    'Bahasa Inggris',
    'Ekonomi',
  ];

  final List<String> goals = [
    'Persiapan UTS/UAS',
    'Pendalaman Konsep',
    'Tugas Akhir',
    'Belajar dari Dasar',
  ];

  final List<String> levels = [
    'Dasar',
    'Menengah',
    'Lanjut',
  ];

  void selectSubject(String subject) {
    selectedSubject.value = subject;
    _findRecommendations();
  }

  void selectGoal(String goal) {
    selectedGoal.value = goal;
  }

  void selectLevel(String level) {
    selectedLevel.value = level;
  }

  void _findRecommendations() {
    if (kUseMock) {
      recommendedTutors.value = mockTutors.where((t) {
        return t.subjects.any((s) =>
            s.toLowerCase().contains(selectedSubject.value.toLowerCase()));
      }).toList();
    }
  }

  void submit() {
    if (selectedSubject.value.isEmpty ||
        selectedGoal.value.isEmpty ||
        selectedLevel.value.isEmpty) {
      return;
    }

    hasSubmitted.value = true;
    _findRecommendations();

    Get.snackbar(
      'Kuesioner Tersimpan',
      '${recommendedTutors.length} tutor cocok ditemukan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToRecommendedTutor(TutorModel tutor) {
    Get.toNamed(AppRoutes.tutorDetail, arguments: tutor);
  }

  void reset() {
    selectedSubject.value = '';
    selectedGoal.value = '';
    selectedLevel.value = '';
    recommendedTutors.clear();
    hasSubmitted.value = false;
  }
}
