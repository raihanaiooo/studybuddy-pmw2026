import 'package:get/get.dart';

import '../core/services/auth_service.dart';
import '../data/profile_repository_supabase.dart';
import '../domain/profile_repository.dart';
import '../models/tutor_document_model.dart';
import '../models/tutor_model.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileRepository? profileRepository})
    : _profiles = profileRepository ?? ProfileRepositorySupabase();

  final ProfileRepository _profiles;
  final _authService = AuthService();

  final RxBool isLoading = false.obs;

  final RxInt completedSessions = 0.obs;
  final RxDouble avgRatingGiven = 0.0.obs;

  final Rx<TutorModel?> tutorProfile = Rx<TutorModel?>(null);

  final RxList<TutorDocumentModel> tutorDocuments = <TutorDocumentModel>[].obs;

  final RxBool profileContractMissing = false.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      if (user.role == 'tutor') {
        await fetchMyTutorProfile();
        await fetchTutorDocuments();
      }
    } catch (_) {}
  }

  Future<void> fetchMyTutorProfile({String? forUserId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      String? uid = forUserId;
      if (uid == null) {
        final user = await _authService.getCurrentUser();
        uid = user?.id;
      }
      if (uid == null) return;
      final data = await _profiles.fetchMyTutorProfile(uid);
      tutorProfile.value = _toTutorModel(data);
    } on ProfileBackendMissingException catch (e) {
      tutorProfile.value = null;
      profileContractMissing.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat profil. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTutorDocuments({String? forUserId}) async {
    isLoading.value = true;
    try {
      String? uid = forUserId;
      if (uid == null) {
        final user = await _authService.getCurrentUser();
        uid = user?.id;
      }
      if (uid == null) return;
      final records = await _profiles.fetchMyTutorDocuments(uid);
      tutorDocuments.value = records.map(_toDocumentModel).toList();
    } on ProfileBackendMissingException catch (e) {
      tutorDocuments.value = [];
      profileContractMissing.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat dokumen. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveBuddyProfile({
    required AuthController auth,
    required String fullName,
    String? phone,
    String? jenjang,
    required List<String> interestedSubjects,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final current = auth.currentUser.value;
      if (current == null) {
        errorMessage.value = 'Sesi berakhir. Login ulang untuk menyimpan.';
        return false;
      }

      // Block Buddy SMP tanpa consent (NFR-AUTH-03)
      if (current.needsParentConsent) {
        errorMessage.value =
            'Persetujuan orang tua diperlukan. Hubungi admin untuk melengkapi data orang tua/wali.';
        Get.snackbar('Persetujuan Diperlukan', errorMessage.value);
        return false;
      }

      await _profiles.updateBuddyProfile(
        current.id,
        BuddyProfilePatch(
          fullName: fullName,
          phone: phone,
          jenjang: jenjang,
          interestedSubjects: interestedSubjects,
        ),
      );
      auth.currentUser.value = current.copyWith(
        fullName: fullName,
        phone: phone,
        jenjang: jenjang,
        interestedSubjects: interestedSubjects,
      );
      Get.snackbar('Berhasil', 'Profil kamu sudah diperbarui');
      return true;
    } on ProfileBackendMissingException catch (e) {
      profileContractMissing.value = true;
      errorMessage.value = e.message;
      Get.snackbar('Gagal menyimpan', e.message);
      return false;
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan profil. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveTutorProfile({
    required String bio,
    required List<String> subjects,
    List<String>? jenjangDiajar,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final current = tutorProfile.value;
      if (current == null) {
        errorMessage.value = 'Profil Tutor belum dimuat.';
        return false;
      }
      await _profiles.updateTutorProfile(
        current.id,
        TutorProfilePatch(
          bio: bio,
          subjects: subjects,
          jenjangDiajar: jenjangDiajar,
        ),
      );
      tutorProfile.value = TutorModel(
        id: current.id,
        userId: current.userId,
        fullName: current.fullName,
        avatarUrl: current.avatarUrl,
        bio: bio,
        subjects: subjects,
        jenjangDiajar: jenjangDiajar ?? current.jenjangDiajar,
        rating: current.rating,
        totalSessions: current.totalSessions,
        totalReviews: current.totalReviews,
        isOnline: current.isOnline,
        pricePerHour: current.pricePerHour,
        gmeetLink: current.gmeetLink,
        university: current.university,
        gpa: current.gpa,
        lastSeen: current.lastSeen,
        verificationStatus: current.verificationStatus,
        verificationNote: current.verificationNote,
      );
      Get.snackbar('Berhasil', 'Profil Tutor sudah diperbarui');
      return true;
    } on ProfileBackendMissingException catch (e) {
      profileContractMissing.value = true;
      errorMessage.value = e.message;
      Get.snackbar('Gagal menyimpan', e.message);
      return false;
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan profil. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void uploadDocument(String documentId) {
    profileContractMissing.value = true;
    errorMessage.value =
        'Unggah dokumen belum tersedia: kontrak storage & akses dokumen '
        '(C-DOC-01..05/D-47) belum dijawab pemilik Back-End.';
    Get.snackbar(
      'Belum tersedia',
      'Kontrak storage dokumen (C-DOC-01..05/D-47) belum dijawab BE.',
    );
  }

  TutorModel _toTutorModel(TutorProfileData d) => TutorModel(
    id: d.id,
    userId: d.userId,
    fullName: d.fullName,
    bio: d.bio,
    subjects: d.subjects,
    jenjangDiajar: d.jenjangDiajar,
    rating: 0.0,
    totalSessions: 0,
    totalReviews: 0,
    isOnline: false,
    pricePerHour: 0.0,
    university: '',
    gpa: 0.0,
    verificationStatus: d.verificationStatus ?? 'pending',
    verificationNote: d.verificationNote,
  );

  TutorDocumentModel _toDocumentModel(TutorDocumentRecord r) {
    final jenis = SrsDocumentType.byJenis(r.jenisDokumen);
    return TutorDocumentModel(
      id: r.id,
      tutorId: r.tutorId,
      type: r.jenisDokumen,
      label: jenis?.label ?? r.jenisDokumen,
      requirement: jenis == null
          ? DocumentRequirement.unclassified
          : _srsRequirement(jenis),
      fileUrl: r.fileUrl,
      status: r.status,
    );
  }

  DocumentRequirement _srsRequirement(SrsDocumentType t) {
    switch (t) {
      case SrsDocumentType.transkrip:
      case SrsDocumentType.kartuIdentitasPelajar:
      case SrsDocumentType.sertifikatPrestasi:
        return DocumentRequirement.required;
      case SrsDocumentType.sertifikatBahasa:
        return DocumentRequirement.conditional;
    }
  }
}
