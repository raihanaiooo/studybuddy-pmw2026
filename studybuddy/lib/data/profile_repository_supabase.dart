import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/supabase_service.dart';
import '../domain/profile_repository.dart';

/// ═══════════════════ PERINGATAN KONTRAK (ISOLASI ASUMSI) ═══════════════════
///
/// Ini SATU-SATUNYA tempat di kodebase yang mengetahui asumsi kolom
/// profil/dokumen. Status kontrak:
///
/// * TERVERIFIKASI (2): tabel `users` + kunci `id`/`full_name`
///   (signUp/getCurrentUser berjalan); tabel `tutors` + kunci `id`/`user_id`
///   (read tutor, updateOnlineStatus, recalc rating berjalan).
/// * ASUMSI (3 — bukan kontrak, menunggu D-45/D-46/D-47/C-DOC-01..09):
///   - kolom Buddy `phone`, `usia`, `kelas`, `asal_sekolah`,
///     `mata_pelajaran_diminati` (belum pernah ditulis kode mana pun);
///   - kolom `kemampuan_lain` (belum pernah ditulis);
///   - tabel dokumen TIDAK PERNAH dirujuk kode klien mana pun — tidak ada
///     konstanta tabelnya di `SupabaseConstants` — nama `tutor_documents`
///     dan seluruh kolomnya murni asumsi;
///   - bucket storage `documents` (D-47) — dideklarasikan, tidak pernah
///     dipakai; TIDAK ADA operasi storage di slice ini.
///
/// Bila asumsi keliru, PostgrestException "relation/column does not exist"
/// dibungkus menjadi [ProfileBackendMissingException] sehingga pemanggil
/// menandai kontrak hilang alih-alih berpura-pura berhasil. Jawaban resmi
/// kontrak cukup untuk mengoreksi berkas ini saja.
/// ═══════════════════════════════════════════════════════════════════════════
class ProfileRepositorySupabase implements ProfileRepository {
  /// ASUMSI (tidak terverifikasi): nama tabel dokumen. Belum ada konstanta
  /// di `SupabaseConstants` karena kontraknya belum dijawab.
  static const String _tableTutorDocuments = 'tutor_documents';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<BuddyProfileData> fetchBuddyProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableUsers)
          .select()
          .eq('id', userId)
          .single();
      final map = data;
      // full_name TERVERIFIKASI; sisanya ASUMSI — dibaca lenient.
      return BuddyProfileData(
        fullName: map['full_name'] as String?,
        phone: map['phone'] as String?,
        age: map['usia'] as int?,
        gradeLevel: map['kelas'] as String?,
        school: map['asal_sekolah'] as String?,
        interestedSubjects: List<String>.from(
          map['mata_pelajaran_diminati'] as List? ?? [],
        ),
      );
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'users');
    }
  }

  @override
  Future<void> updateBuddyProfile(String userId, BuddyProfilePatch patch) async {
    if (patch.isEmpty) return;
    final values = _buddyPatchValues(patch);
    if (values.isEmpty) {
      // Patch yang tidak memetakan ke kolom mana pun TIDAK dianggap sukses —
      // dilempar agar pemanggil tidak menampilkan snackbar palsu.
      throw const ProfileBackendMissingException(
        'Patch profil Buddy tidak memetakan ke kolom backend mana pun — '
        'kontrak kolom profil (C-AUTH-03/D-45) belum dijawab.',
      );
    }
    try {
      await _client
          .from(SupabaseConstants.tableUsers)
          .update(values)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'users');
    }
  }

  @override
  Future<TutorProfileData> fetchMyTutorProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableTutors)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) {
        throw const ProfileBackendMissingException(
          'Belum ada profil Tutor untuk user ini — baris tutors belum '
          'dibuat backend (hubungannya User→Tutor 1:1, C-TUT-01).',
        );
      }
      final map = data;
      return TutorProfileData(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        // full_name ada di baris tutors pada baca tutor yang berjalan;
        // bila backend tidak menyimpannya di sini, kontrak C-TUT-01
        // menjawabnya dan hanya berkas ini yang dikoreksi.
        fullName: map['full_name'] as String? ?? '',
        // bio/mata_pelajaran/status_verifikasi eksplisit SRS §4.1.
        bio: map['bio'] as String? ?? '',
        subjects: List<String>.from(map['mata_pelajaran'] as List? ?? []),
        verificationStatus: map['status_verifikasi'] as String?,
        rejectionReason: map['rejection_reason'] as String?,
      );
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'tutors');
    }
  }

  @override
  Future<void> updateTutorProfile(String tutorId, TutorProfilePatch patch) async {
    if (patch.isEmpty) return;
    final values = <String, dynamic>{
      if (patch.bio != null) 'bio': patch.bio,
      if (patch.subjects != null) 'mata_pelajaran': patch.subjects,
      // ASUMSI kolom (belum pernah ditulis kode mana pun): D-46/C-TUT-01.
      if (patch.extraSkills != null) 'kemampuan_lain': patch.extraSkills,
    };
    if (values.isEmpty) {
      throw const ProfileBackendMissingException(
        'Patch profil Tutor tidak memetakan ke kolom backend mana pun.',
      );
    }
    try {
      await _client
          .from(SupabaseConstants.tableTutors)
          .update(values)
          .eq('id', tutorId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'tutors');
    }
  }

  @override
  Future<List<TutorDocumentRecord>> fetchMyTutorDocuments(String tutorId) async {
    try {
      final data = await _client
          .from(_tableTutorDocuments)
          .select()
          .eq('tutor_id', tutorId)
          .order('id', ascending: true);
      return data.map((e) => _toRecord(e)).toList();
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, _tableTutorDocuments);
    }
  }

  TutorDocumentRecord _toRecord(Map<String, dynamic> map) =>
      TutorDocumentRecord(
        id: map['id'] as String,
        tutorId: map['tutor_id'] as String,
        jenisDokumen: map['jenis_dokumen'] as String,
        fileUrl: map['file_url'] as String?,
        status: map['status'] as String? ?? 'belum_upload',
      );

  Map<String, dynamic> _buddyPatchValues(BuddyProfilePatch patch) {
    // `full_name` TERVERIFIKASI (ditulis signUp yang berjalan). Sisanya
    // ASUMSI D-45/C-AUTH-03 — nama kolom mengikuti mapping UserModel yang
    // ada, yang belum pernah dibuktikan oleh backend.
    return {
      if (patch.hasFullName) 'full_name': patch.fullName,
      if (patch.hasPhone) 'phone': patch.phone,
      if (patch.hasAge) 'usia': patch.age,
      if (patch.hasGradeLevel) 'kelas': patch.gradeLevel,
      if (patch.hasSchool) 'asal_sekolah': patch.school,
      if (patch.interestedSubjects != null)
        'mata_pelajaran_diminati': patch.interestedSubjects,
    };
  }

  /// Pembungkus tunggal untuk gagal-kenal-skema — pola yang sama dengan
  /// AvailabilitySlotRepositorySupabase (Wave 2.1).
  ProfileBackendMissingException _wrapMissing(PostgrestException e, String table) {
    final m = e.message.toLowerCase();
    final missing =
        m.contains('does not exist') ||
        m.contains('could not find the table') ||
        m.contains('schema cache');
    return missing
        ? ProfileBackendMissingException(
          'Kontrak profil/dokumen belum terverifikasi: tabel/kolom '
          '"$table" tidak dikenal backend. Minta jawaban kontrak '
          '(C-AUTH-03/D-45, C-TUT-01/D-46, C-DOC-01..09/D-47) ke pemilik '
          'Back-End sebelum lanjut.',
          e,
        )
        : ProfileBackendMissingException(
          'Operasi profil/dokumen gagal (bukan skema): ${e.message}',
          e,
        );
  }
}
