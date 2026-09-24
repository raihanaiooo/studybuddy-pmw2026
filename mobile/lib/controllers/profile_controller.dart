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

  /// Upload dokumen verifikasi Tutor ke Supabase Storage (FR-PROF-05/09)
  Future<bool> uploadDocument({
    required String documentId,
    required String jenisDokumen,
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    // Validasi ukuran (max 5MB)
    const maxSize = 5 * 1024 * 1024;
    if (fileBytes.length > maxSize) {
      errorMessage.value = 'Ukuran file maksimal 5MB.';
      Get.snackbar('File Terlalu Besar', errorMessage.value);
      return false;
    }

    // Validasi ekstensi
    final ext = fileName.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
      errorMessage.value = 'Format file harus JPG, PNG, atau PDF.';
      Get.snackbar('Format Tidak Didukung', errorMessage.value);
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final current = tutorProfile.value;
      if (current == null) {
        errorMessage.value = 'Profil Tutor belum dimuat.';
        return false;
      }

      final updated = await _profiles.uploadDocument(
        documentId: documentId,
        tutorId: current.id,
        jenisDokumen: jenisDokumen,
        filePath: filePath,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      // Update state lokal
      final idx = tutorDocuments.indexWhere((d) => d.id == documentId);
      if (idx >= 0) {
        tutorDocuments[idx] = TutorDocumentModel(
          id: updated.id,
          tutorId: updated.tutorId,
          type: updated.jenisDokumen,
          label: tutorDocuments[idx].label,
          requirement: tutorDocuments[idx].requirement,
          fileUrl: updated.fileUrl,
          status: updated.status,
        );
      }

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil diunggah. Menunggu verifikasi Admin.',
      );
      return true;
    } on ProfileBackendMissingException catch (e) {
      profileContractMissing.value = true;
      errorMessage.value = e.message;
      Get.snackbar('Gagal Upload', e.message);
      return false;
    } catch (e) {
      print('ProfileController.uploadDocument error: $e');
      errorMessage.value = 'Gagal upload dokumen. Coba lagi.';
      Get.snackbar('Gagal Upload', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload avatar (Buddy atau Tutor)
  Future<bool> uploadAvatar({
    required AuthController auth,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    // Validasi ukuran (max 5MB)
    const maxSize = 5 * 1024 * 1024;
    if (fileBytes.length > maxSize) {
      errorMessage.value = 'Ukuran foto maksimal 5MB.';
      Get.snackbar('Foto Terlalu Besar', errorMessage.value);
      return false;
    }

    // Validasi ekstensi
    final ext = fileName.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      errorMessage.value = 'Format foto harus JPG, PNG, atau WEBP.';
      Get.snackbar('Format Tidak Didukung', errorMessage.value);
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final current = auth.currentUser.value;
      if (current == null) {
        errorMessage.value = 'Sesi berakhir.';
        return false;
      }

      final url = await _profiles.uploadAvatar(
        userId: current.id,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      auth.currentUser.value = current.copyWith(avatarUrl: url);
      Get.snackbar('Berhasil', 'Foto profil sudah diperbarui');
      return true;
    } on ProfileBackendMissingException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Gagal Upload', e.message);
      return false;
    } catch (e) {
      print('ProfileController.uploadAvatar error: $e');
      errorMessage.value = 'Gagal upload foto. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus avatar
  Future<bool> deleteAvatar({required AuthController auth}) async {
    isLoading.value = true;
    try {
      final current = auth.currentUser.value;
      if (current == null) return false;

      await _profiles.deleteAvatar(current.id);
      auth.currentUser.value = current.copyWith(avatarUrl: null);
      Get.snackbar('Berhasil', 'Foto profil sudah dihapus');
      return true;
    } catch (e) {
      print('ProfileController.deleteAvatar error: $e');
      Get.snackbar('Gagal', 'Tidak bisa menghapus foto. Coba lagi.');
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
