import 'package:get/get.dart';
import '../models/tutor_model.dart';
import '../models/tutor_document_model.dart';
import 'auth_controller.dart';

/// Controller profil Buddy & Tutor (FR-PROF-01..12)
///
/// Masih pakai dummy data mengikuti alur contract-first tim: tinggal ganti
/// isi fetch/save dengan query Supabase begitu Raihana menuliskan kontrak
/// fungsi untuk modul Profil (storage dokumen, update tabel users/tutors).
class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  // Statistik riwayat Buddy (FR-PROF-04)
  final RxInt completedSessions = 12.obs;
  final RxDouble avgRatingGiven = 4.6.obs;

  // Profil publik Tutor yang sedang login (dummy)
  final Rx<TutorModel> tutorProfile = TutorModel(
    id: 'tutor-me',
    userId: 'me',
    fullName: 'Aditya Pratama',
    bio: 'Mahasiswa Teknik Informatika, suka ngajar Kalkulus & Fisika Dasar.',
    subjects: const ['Kalkulus', 'Fisika Dasar', 'Aljabar Linear'],
    rating: 4.8,
    totalSessions: 34,
    totalReviews: 21,
    isOnline: true,
    pricePerHour: 50000,
    university: 'Politeknik Negeri Bandung',
    gpa: 3.7,
    extraSkills: const ['Bimbingan OSN Matematika'],
    verificationStatus: 'verified',
    isTutorOfTheMonth: true,
  ).obs;

  final RxList<TutorDocumentModel> tutorDocuments =
      <TutorDocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTutorDocuments();
  }

  Future<void> fetchTutorDocuments() async {
    isLoading.value = true;
    tutorDocuments.value = _dummyDocuments;
    isLoading.value = false;
  }

  void toggleEditing() => isEditing.value = !isEditing.value;

  /// Simpan perubahan profil Buddy (FR-PROF-03)
  Future<void> saveBuddyProfile({
    required AuthController auth,
    required String fullName,
    String? phone,
    int? age,
    String? gradeLevel,
    String? school,
    required List<String> interestedSubjects,
  }) async {
    isLoading.value = true;
    final current = auth.currentUser.value;
    if (current != null) {
      auth.currentUser.value = current.copyWith(
        fullName: fullName,
        phone: phone,
        age: age,
        gradeLevel: gradeLevel,
        school: school,
        interestedSubjects: interestedSubjects,
      );
    }
    isEditing.value = false;
    isLoading.value = false;
    Get.snackbar('Berhasil', 'Profil kamu sudah diperbarui');
  }

  /// Simpan perubahan bio/mapel/kemampuan lain Tutor (FR-PROF-11)
  Future<void> saveTutorProfile({
    required String bio,
    required List<String> subjects,
    required List<String> extraSkills,
  }) async {
    isLoading.value = true;
    final current = tutorProfile.value;
    tutorProfile.value = TutorModel(
      id: current.id,
      userId: current.userId,
      fullName: current.fullName,
      avatarUrl: current.avatarUrl,
      bio: bio,
      subjects: subjects,
      rating: current.rating,
      totalSessions: current.totalSessions,
      totalReviews: current.totalReviews,
      isOnline: current.isOnline,
      pricePerHour: current.pricePerHour,
      gmeetLink: current.gmeetLink,
      university: current.university,
      gpa: current.gpa,
      lastSeen: current.lastSeen,
      extraSkills: extraSkills,
      verificationStatus: current.verificationStatus,
      rejectionReason: current.rejectionReason,
      isTutorOfTheMonth: current.isTutorOfTheMonth,
    );
    isEditing.value = false;
    isLoading.value = false;
    Get.snackbar('Berhasil', 'Profil Tutor sudah diperbarui');
  }

  /// Placeholder unggah dokumen — integrasi file picker & Supabase Storage
  /// menyusul sesuai kontrak BE (NFR-PROF-01..03).
  void uploadDocument(String documentId) {
    final index = tutorDocuments.indexWhere((d) => d.id == documentId);
    if (index == -1) return;
    tutorDocuments[index] = tutorDocuments[index].copyWith(
      status: 'menunggu',
      fileUrl: 'pending-upload',
    );
    Get.snackbar('Diunggah', 'Dokumen menunggu verifikasi Admin');
  }

  static final List<TutorDocumentModel> _dummyDocuments = [
    const TutorDocumentModel(
      id: 'doc-transkrip',
      tutorId: 'tutor-me',
      type: 'transkrip',
      label: 'Transkrip Nilai',
      requirement: DocumentRequirement.required,
      status: 'terverifikasi',
      fileUrl: 'dummy://transkrip.pdf',
    ),
    const TutorDocumentModel(
      id: 'doc-ktm',
      tutorId: 'tutor-me',
      type: 'ktm',
      label: 'KTM / Kartu Tanda Pelajar',
      requirement: DocumentRequirement.required,
      status: 'terverifikasi',
      fileUrl: 'dummy://ktm.jpg',
    ),
    const TutorDocumentModel(
      id: 'doc-bahasa',
      tutorId: 'tutor-me',
      type: 'sertifikat_bahasa',
      label: 'Sertifikat Bahasa (wajib jika mengajar kelas bahasa)',
      requirement: DocumentRequirement.conditional,
    ),
    const TutorDocumentModel(
      id: 'doc-utbk',
      tutorId: 'tutor-me',
      type: 'skor_utbk',
      label: 'Skor/Kartu UTBK (wajib jika mengajar subtes UTBK)',
      requirement: DocumentRequirement.conditional,
    ),
    const TutorDocumentModel(
      id: 'doc-prestasi',
      tutorId: 'tutor-me',
      type: 'sertifikat_prestasi',
      label: 'Sertifikat Prestasi',
      requirement: DocumentRequirement.optional,
    ),
    const TutorDocumentModel(
      id: 'doc-cv',
      tutorId: 'tutor-me',
      type: 'cv',
      label: 'CV / Portfolio',
      requirement: DocumentRequirement.optional,
    ),
  ];
}
