import 'package:get/get.dart';

import '../core/services/auth_service.dart';
import '../data/profile_repository_supabase.dart';
import '../domain/profile_repository.dart';
import '../models/tutor_document_model.dart';
import '../models/tutor_model.dart';
import 'auth_controller.dart';

/// Controller profil Buddy & Tutor (FR-PROF-01..12) — Wave 2.3.
///
/// Persistensi kini lewat [ProfileRepository] (implementasi Supabase di
/// `lib/data/profile_repository_supabase.dart`):
/// * State UI hanya diperbarui SETELAH backend mengonfirmasi — tidak ada
///   lagi snackbar "Berhasil" di atas mutasi memori.
/// * Kegagalan kontrak (kolom/tabel/bucket tidak dikenal) dilaporkan jujur
///   lewat [profileContractMissing]/[errorMessage], bukan disamarkan.
/// * Profil Tutor TIDAK lagi di-hardcode dan katalog enam dokumen lama
///   TIDAK lagi dipakai sebagai pengganti data (konflik SRS — D-17).
class ProfileController extends GetxController {
  ProfileController({ProfileRepository? profileRepository})
    : _profiles = profileRepository ?? ProfileRepositorySupabase();

  final ProfileRepository _profiles;
  final _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  // Statistik riwayat Buddy (FR-PROF-04) — masih angka dummy mengikuti alur
  // contract-first: kontrak pembacaan statistiknya belum dijawab BE dan
  // bukan bagian slice persistensi profil ini. TIDAK dijadikan sukses palsu
  // untuk klaim lain.
  final RxInt completedSessions = 0.obs;
  final RxDouble avgRatingGiven = 0.0.obs;

  /// Profil publik Tutor milik user yang login — dari backend. Null berarti
  /// belum termuat atau backend tidak mengenal barisnya (C-TUT-01/D-46).
  final Rx<TutorModel?> tutorProfile = Rx<TutorModel?>(null);

  /// Dokumen verifikasi milik Tutor yang login — dari backend. Kosong bila
  /// kontrak tabel dokumen (C-DOC-01..09/D-47) belum dijawab — KOSONG
  /// DENGAN PENANDA, bukan kosong yang berpura-pura "belum ada dokumen".
  final RxList<TutorDocumentModel> tutorDocuments = <TutorDocumentModel>[].obs;

  /// True bila kegagalan terakhir disebabkan kontrak profil/dokumen belum
  /// dijawab BE (C-AUTH-03/D-45, C-TUT-01/D-46, C-DOC-01..09/D-47) — bukan
  /// error transient.
  final RxBool profileContractMissing = false.obs;

  /// Pesan kegagalan terakhir untuk permukaan UI.
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  /// Muat ulang data milik user yang login. Buddy memakai profil dari
  /// [AuthController] (baca `users` terverifikasi); Tutor memuat profil
  /// dan dokumennya dari [ProfileRepository].
  Future<void> reload() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      if (user.role == 'tutor') {
        await fetchMyTutorProfile();
        await fetchTutorDocuments();
      }
    } catch (_) {
      // Tanpa sesi/Supabase (mis. widget test) — dibiarkan tanpa data;
      // tidak ada data dummy pengganti.
    }
  }

  /// Muat profil Tutor milik user yang login dari backend (FR-PROF-04/10).
  ///
  /// [forUserId] memaksa identitas eksplisit — hanya untuk test tanpa
  /// Supabase; di produksi selalu null (identitas dari sesi).
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

  /// Muat dokumen verifikasi milik Tutor yang login (FR-PROF-05/06).
  ///
  /// Kontrak tabel dokumen (C-DOC-01..09/D-47) belum dijawab BE. Baca yang
  /// gagal kenal-skema dilaporkan jujur: daftar tetap kosong dan
  /// [profileContractMissing] bernilai true — katalog enam dokumen lama
  /// TIDAK dipakai lagi sebagai pengganti data.
  ///
  /// [forUserId] memaksa identitas eksplisit — hanya untuk test tanpa
  /// Supabase; di produksi selalu null (identitas dari sesi).
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

  void toggleEditing() => isEditing.value = !isEditing.value;

  /// Simpan perubahan profil Buddy (FR-PROF-02) — persist ke backend lewat
  /// [ProfileRepository]. Email TIDAK dikirim (SRS: Buddy tidak boleh
  /// mengubah email). Mengembalikan true HANYA bila backend mengonfirmasi;
  /// state UI ikut diperbarui hanya saat itu.
  // Ganti field statistik dummy jadi 0 (belum ada sumber data riil)

  // Ganti method saveBuddyProfile jadi:
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

  /// Simpan perubahan bio/mapel/kemampuan lain Tutor (FR-PROF-09/11) —
  /// persist ke backend. Mengembalikan true HANYA bila backend
  /// mengonfirmasi; state UI ikut diperbarui hanya saat itu.
  Future<bool> saveTutorProfile({
    required String bio,
    required List<String> subjects,
    required List<String> extraSkills,
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
          extraSkills: extraSkills,
        ),
      );
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
      Get.snackbar('Berhasil', 'Profil Tutor sudah diperbarui');
      return true;
    } on ProfileBackendMissingException catch (e) {
      profileContractMissing.value = true;
      errorMessage.value = e.message;
      Get.snackbar(
        'Gagal menyimpan',
        'Kontrak profil Tutor (C-TUT-01/D-46) belum dijawab pemilik '
            'Back-End — perubahan tidak tersimpan.',
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan profil. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Unggah/ganti dokumen verifikasi (NFR-PROF-01..03).
  ///
  /// BELUM DAPAT diimplementasi: kontrak storage dokumen — bucket privat,
  /// aturan akses RLS, format & batas ukuran (C-DOC-01..05/D-47) — belum
  /// dijawab pemilik Back-End. Aksi ini melaporkan kontrak hilang; TIDAK
  /// ada lagi status lokal palsu ('menunggu' + 'pending-upload' dihapus).
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

  /// Petakan hasil baca domain ke model UI. Hanya field TERVERIFIKASI/SRS
  /// yang diisi; field tambahan (agregat, harga, universitas, dst.) nol
  /// sampai C-TUT-01/D-46 dijawab — bukan diisi angka karangan.
  TutorModel _toTutorModel(TutorProfileData d) => TutorModel(
    id: d.id,
    userId: d.userId,
    fullName: d.fullName,
    bio: d.bio,
    subjects: d.subjects,
    rating: 0.0,
    totalSessions: 0,
    totalReviews: 0,
    isOnline: false,
    pricePerHour: 0.0,
    university: '',
    gpa: 0.0,
    extraSkills: const [],
    // null = backend tidak mengenali kolom status (C-TUT-03 terbuka);
    // diperlakukan konservatif sebagai 'pending' (bukan 'verified').
    verificationStatus: d.verificationStatus ?? 'pending',
    rejectionReason: d.rejectionReason,
  );

  /// Petakan dokumen hasil baca ke model UI. Klasifikasi untuk empat jenis
  /// yang EKSPLISIT disebut SRS FR-PROF-05 diambil dari SRS (otentik);
  /// jenis lain di luar SRS dilaporkan jujur sebagai
  /// [DocumentRequirement.unclassified] sampai D-17/C-DOC-07 dijawab.
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

  /// Klasifikasi SRS FR-PROF-05 per jenis. Catatan D-17: SRS menempatkan
  /// sertifikat prestasi di set wajib meski aturan fallback untuk Tutor
  /// tanpa prestasi tidak dispesifikasi — klasifikasi final tetap
  /// menunggu D-17, tetapi teks SRS tetap acuan otentik.
  DocumentRequirement _srsRequirement(SrsDocumentType t) {
    switch (t) {
      case SrsDocumentType.transkrip:
      case SrsDocumentType.kartuIdentitasPelajar:
        return DocumentRequirement.required;
      case SrsDocumentType.sertifikatPrestasi:
        return DocumentRequirement.required;
      case SrsDocumentType.sertifikatBahasa:
        return DocumentRequirement.conditional;
    }
  }
}
