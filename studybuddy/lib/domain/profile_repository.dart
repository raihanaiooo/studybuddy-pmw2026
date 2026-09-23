/// Kontrak penyimpanan profil & dokumen — batas domain/aplikasi (Wave 2.3).
///
/// Implementasi konkret ada di `lib/data/profile_repository_supabase.dart`
/// (arsitektur: antarmuka repository di batas domain, implementasi di data;
/// domain bebas dari Flutter/Supabase).
///
/// ═══════════════════ STATUS KONTRAK BACKEND (WAJIB DIBACA) ═══════════════════
///
/// Klasifikasi tiap field (aturan kontrak: hanya (1) SRS eksplisit dan
/// (2) terverifikasi kode yang berjalan yang otentik):
///
/// * TERVERIFIKASI (2): tabel `users` + kolom kunci `id`, `full_name`
///   (dipakai `signUp`/`getCurrentUser` yang berjalan); tabel `tutors` +
///   kunci `id` dan `user_id` (dipakai read tutor dan update
///   `is_online`/`rating` yang berjalan).
/// * SRS EKSPLISIT (1): `bio`, `mata_pelajaran`, `status_verifikasi`
///   (§4.1 TutorProfile); alasan penolakan verifikasi (FR-PROF-07);
///   Buddy boleh mengedit profilnya kecuali email (FR-PROF-02).
/// * ASUMSI (3 — bukan kontrak): kolom Buddy `phone`, `usia`, `kelas`,
///   `asal_sekolah`, `mata_pelajaran_diminati` (D-45/C-AUTH-03 terbuka);
///   kolom `kemampuan_lain` (D-46/C-TUT-01 terbuka); tabel dokumen dan
///   seluruh kolomnya (C-DOC-06 terbuka); bucket storage dokumen
///   (C-DOC-01..05/D-47 terbuka).
///
/// Akses profil/dokumen dipusatkan DI ANTARMUKA INI; nama tabel/kolom yang
/// belum terverifikasi adalah asumsi eksplisit yang terisolasi di berkas
/// implementasi data dan siap dikoreksi begitu kontrak dijawab. Saat
/// backend membuktikan asumsi keliru, implementasi melempar
/// [ProfileBackendMissingException] — pemanggil menandai kontrak HILANG,
/// bukan berpura-pura berhasil.
/// ════════════════════════════════════════════════════════════════════════════
abstract class ProfileRepository {
  /// Baca profil Buddy milik [userId] (FR-PROF-01).
  Future<BuddyProfileData> fetchBuddyProfile(String userId);

  /// Simpan perubahan profil Buddy (FR-PROF-02 — email TIDAK termasuk,
  /// sesuai SRS). Field yang tidak dikirim tidak ditulis.
  Future<void> updateBuddyProfile(String userId, BuddyProfilePatch patch);

  /// Baca profil publik Tutor milik user yang login (FR-PROF-04/10) via
  /// kunci `user_id` yang TERVERIFIKASI. Hanya field SRS yang dibaca;
  /// field tambahan (harga, agregat, universitas) menunggu C-TUT-01/D-46.
  Future<TutorProfileData> fetchMyTutorProfile(String userId);

  /// Simpan perubahan bio/mapel/kemampuan lain Tutor (FR-PROF-09/11).
  Future<void> updateTutorProfile(String tutorId, TutorProfilePatch patch);

  /// Baca dokumen verifikasi milik [tutorId] (FR-PROF-05/06). Melempar
  /// [ProfileBackendMissingException] selama kontrak tabel dokumen
  /// (C-DOC-01..09/D-47) belum terverifikasi.
  Future<List<TutorDocumentRecord>> fetchMyTutorDocuments(String tutorId);
}

// ═══════════════════════════ RECORD hasil baca ═══════════════════════════

/// Data profil Buddy hasil baca. Null berarti kolom kosong/tidak tersimpan.
class BuddyProfileData {
  final String? fullName;
  final String? phone;
  final int? age;
  final String? gradeLevel;
  final String? school;
  final List<String> interestedSubjects;

  const BuddyProfileData({
    this.fullName,
    this.phone,
    this.age,
    this.gradeLevel,
    this.school,
    this.interestedSubjects = const [],
  });
}

/// Data profil Tutor hasil baca.
///
/// [verificationStatus] null berarti backend tidak mengenali kolom status
/// verifikasi (C-TUT-03 terbuka) — penelepon wajib memperlakukannya secara
/// konservatif (bukan 'verified').
class TutorProfileData {
  final String id;
  final String userId;
  final String fullName;
  final String bio;
  final List<String> subjects;
  final String? verificationStatus;
  final String? rejectionReason;

  const TutorProfileData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.subjects,
    this.verificationStatus,
    this.rejectionReason,
  });
}

/// Satu dokumen verifikasi hasil baca. [status] memakai kosakata klien
/// yang ada (`belum_upload|menunggu|terverifikasi|ditolak`) yang status
/// kanoniknya sendiri belum dijawab (C-TUT-03) — TIDAK dinormalisasi di sini.
class TutorDocumentRecord {
  final String id;
  final String tutorId;
  final String jenisDokumen;
  final String? fileUrl;
  final String status;

  const TutorDocumentRecord({
    required this.id,
    required this.tutorId,
    required this.jenisDokumen,
    this.fileUrl,
    required this.status,
  });
}

// ═══════════════════════════ PATCH tulis ═══════════════════════════

/// Sentinel pembeda "field tidak dikirim" dari "dikirim null secara sengaja"
/// (pola yang sama dengan `UserModel.copyWith`).
const Object _unset = Object();

/// Perubahan profil Buddy yang akan disimpan (FR-PROF-02).
///
/// `phone/age/gradeLevel/school` default ke sentinel [_unset]: mengirim null
/// berarti mengosongkan field secara sengaja dan akan ditulis sebagai null.
/// [interestedSubjects] null = tidak diubah; daftar kosong = mengosongkan.
class BuddyProfilePatch {
  BuddyProfilePatch({
    Object? fullName = _unset,
    Object? phone = _unset,
    Object? age = _unset,
    Object? gradeLevel = _unset,
    Object? school = _unset,
    this.interestedSubjects,
  }) : _fullName = fullName,
       _phone = phone,
       _age = age,
       _gradeLevel = gradeLevel,
       _school = school;

  final Object? _fullName;
  final Object? _phone;
  final Object? _age;
  final Object? _gradeLevel;
  final Object? _school;
  final List<String>? interestedSubjects;

  bool get hasFullName => !identical(_fullName, _unset);
  String? get fullName => hasFullName ? _fullName as String? : null;

  bool get hasPhone => !identical(_phone, _unset);
  String? get phone => hasPhone ? _phone as String? : null;

  bool get hasAge => !identical(_age, _unset);
  int? get age => hasAge ? _age as int? : null;

  bool get hasGradeLevel => !identical(_gradeLevel, _unset);
  String? get gradeLevel => hasGradeLevel ? _gradeLevel as String? : null;

  bool get hasSchool => !identical(_school, _unset);
  String? get school => hasSchool ? _school as String? : null;

  bool get isEmpty =>
      !hasFullName &&
      !hasPhone &&
      !hasAge &&
      !hasGradeLevel &&
      !hasSchool &&
      interestedSubjects == null;
}

/// Perubahan profil Tutor yang akan disimpan (FR-PROF-09/11).
/// null = tidak diubah; string/daftar kosong = mengosongkan.
class TutorProfilePatch {
  final String? bio;
  final List<String>? subjects;
  final List<String>? extraSkills;

  const TutorProfilePatch({this.bio, this.subjects, this.extraSkills});

  bool get isEmpty => bio == null && subjects == null && extraSkills == null;
}

// ═══════════════════ KATALOG DOKUMEN SRS (D-17) ═══════════════════

/// Katalog dokumen yang EKSPLISIT disebut SRS FR-PROF-05 — dipakai sebagai
/// acuan domain, BUKAN sebagai katalog tampilan yang digenerasi klien.
///
/// Katalog enam dokumen lama klien (transkrip, KTM, sertifikat bahasa,
/// skor UTBK, sertifikat prestasi, CV) KONFLIK dengan SRS — UTBK dan CV
/// tidak ada di SRS, dan SRS menempatkan sertifikat prestasi di set wajib
/// sementara klien lama menandainya opsional (lihat D-17). Katalog lama
/// TIDAK dipertahankan; katalog pengganti TIDAK dikarang. Klasifikasi
/// final wajib/bersyarat per jenis tetap menunggu jawaban D-17/C-DOC-07.
enum SrsDocumentType {
  transkrip(
    'transkrip',
    'Transkrip Nilai',
    'Wajib',
  ),
  kartuIdentitasPelajar(
    'kartu_identitas_pelajar',
    'KTM / Kartu Tanda Pelajar',
    'Wajib',
  ),
  sertifikatPrestasi(
    'sertifikat_prestasi',
    'Sertifikat Prestasi',
    'Wajib (klasifikasi final menunggu D-17)',
  ),
  sertifikatBahasa(
    'sertifikat_bahasa',
    'Sertifikat Bahasa',
    'Bersyarat — khusus Tutor kelas bahasa asing',
  );

  const SrsDocumentType(this.jenis, this.label, this.srsRequirementText);

  /// Nilai jenis dokumen gaya snake_case mengikuti penamaan kolom Bahasa
  /// Indonesia yang terbukti dipakai tabel lain — ASUMSI, bukan kontrak.
  final String jenis;

  /// Label tampilan milik UI (bukan kontrak backend).
  final String label;

  /// Klasifikasi sesuai teks SRS FR-PROF-05.
  final String srsRequirementText;

  static SrsDocumentType? byJenis(String jenis) {
    for (final t in SrsDocumentType.values) {
      if (t.jenis == jenis) return t;
    }
    return null;
  }
}

// ═══════════════════ EXCEPTION kontrak hilang ═══════════════════

/// Backend membuktikan kontrak profil/dokumen belum ada (tabel/kolom tidak
/// dikenal schema cache) atau operasi backend gagal. Kontrak terkait
/// (C-AUTH-03/D-45, C-TUT-01/D-46, C-DOC-01..09/D-47) tetap TERBUKA —
/// exception ini menandai keadaan, bukan menjawabnya.
class ProfileBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const ProfileBackendMissingException(this.message, [this.cause]);

  @override
  String toString() =>
      'ProfileBackendMissingException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
