import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/supabase_service.dart';
import '../domain/profile_repository.dart';
import 'dart:typed_data';

class ProfileRepositorySupabase implements ProfileRepository {
  static const String _tableTutorDocuments = 'tutor_documents';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      final storagePath = '$userId/avatar.$ext';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            storagePath,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from('avatars')
          .getPublicUrl(storagePath);
      // Tambah timestamp agar tidak cached
      final urlWithCache =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await _client
          .from(SupabaseConstants.tableUsers)
          .update({'avatar_url': urlWithCache})
          .eq('id', userId);

      return urlWithCache;
    } on StorageException catch (e) {
      throw ProfileBackendMissingException(
        'Upload avatar gagal: ${e.message}',
        e,
      );
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'users');
    }
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    try {
      // Hapus file dari storage (best-effort)
      try {
        final data = await _client
            .from(SupabaseConstants.tableUsers)
            .select('avatar_url')
            .eq('id', userId)
            .maybeSingle();
        final url = data?['avatar_url'] as String?;
        if (url != null && url.isNotEmpty) {
          // Parse path dari URL
          final uri = Uri.parse(url);
          final pathSegments = uri.pathSegments;
          final avatarIdx = pathSegments.indexOf('avatars');
          if (avatarIdx >= 0 && avatarIdx < pathSegments.length - 1) {
            final path = pathSegments.sublist(avatarIdx + 1).join('/');
            await _client.storage.from('avatars').remove([path]);
          }
        }
      } catch (_) {
        // Best-effort: kalau gagal hapus file, tetap lanjut hapus URL
      }

      await _client
          .from(SupabaseConstants.tableUsers)
          .update({'avatar_url': null})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'users');
    }
  }

  @override
  Future<BuddyProfileData> fetchBuddyProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableUsers)
          .select()
          .eq('id', userId)
          .single();

      return BuddyProfileData(
        fullName: data['full_name'] as String?,
        phone: data['phone'] as String?,
        jenjang: data['jenjang'] as String?,
        interestedSubjects: List<String>.from(
          data['interested_subjects'] as List? ?? [],
        ),
      );
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'users');
    }
  }

  @override
  Future<void> updateBuddyProfile(
    String userId,
    BuddyProfilePatch patch,
  ) async {
    if (patch.isEmpty) return;
    final values = _buddyPatchValues(patch);
    if (values.isEmpty) {
      throw const ProfileBackendMissingException('Patch profil Buddy kosong.');
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

  Map<String, dynamic> _buddyPatchValues(BuddyProfilePatch patch) => {
    if (patch.fullName != null) 'full_name': patch.fullName,
    if (patch.phone != null) 'phone': patch.phone,
    if (patch.jenjang != null) 'jenjang': patch.jenjang,
    if (patch.interestedSubjects != null)
      'interested_subjects': patch.interestedSubjects,
  };

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
          'Belum ada profil Tutor untuk user ini.',
        );
      }
      return TutorProfileData(
        id: data['id'] as String,
        userId: data['user_id'] as String,
        fullName: data['full_name'] as String? ?? '',
        bio: data['bio'] as String? ?? '',
        subjects: List<String>.from(data['subjects'] as List? ?? []),
        jenjangDiajar: List<String>.from(data['jenjang_diajar'] as List? ?? []),
        verificationStatus: data['verification_status'] as String?,
        verificationNote: data['verification_note'] as String?,
      );
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, 'tutors');
    }
  }

  @override
  Future<void> updateTutorProfile(
    String tutorId,
    TutorProfilePatch patch,
  ) async {
    if (patch.isEmpty) return;
    final values = <String, dynamic>{
      if (patch.bio != null) 'bio': patch.bio,
      if (patch.subjects != null) 'subjects': patch.subjects,
      if (patch.jenjangDiajar != null) 'jenjang_diajar': patch.jenjangDiajar,
    };
    if (values.isEmpty) {
      throw const ProfileBackendMissingException('Patch profil Tutor kosong.');
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
  Future<List<TutorDocumentRecord>> fetchMyTutorDocuments(
    String tutorId,
  ) async {
    try {
      final data = await _client
          .from(_tableTutorDocuments)
          .select()
          .eq('tutor_id', tutorId)
          .order('jenis_dokumen', ascending: true);
      return data.map(_toRecord).toList();
    } on PostgrestException catch (e) {
      throw _wrapMissing(e, _tableTutorDocuments);
    }
  }

  @override
  Future<TutorDocumentRecord> uploadDocument({
    required String documentId,
    required String tutorId,
    required String jenisDokumen,
    required String filePath,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      // Tentukan ekstensi file
      final ext = fileName.split('.').last.toLowerCase();
      // Path di bucket: {tutor_id}/{document_id}.{ext}
      final storagePath = '$tutorId/$documentId.$ext';

      // Upload file ke Supabase Storage (upsert = replace kalau sudah ada)
      await _client.storage
          .from('documents')
          .uploadBinary(
            storagePath,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(upsert: true),
          );

      // Ambil public URL (walaupun bucket private, URL tetap valid untuk RLS)
      final fileUrl = _client.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // Update metadata di tabel
      final now = DateTime.now().toIso8601String();
      final updated = await _client
          .from(_tableTutorDocuments)
          .update({
            'file_url': fileUrl,
            'status': 'menunggu_verifikasi',
            'uploaded_at': now,
          })
          .eq('id', documentId)
          .select()
          .single();

      return _toRecord(updated);
    } on StorageException catch (e) {
      throw ProfileBackendMissingException(
        'Upload file gagal: ${e.message}',
        e,
      );
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

  ProfileBackendMissingException _wrapMissing(
    PostgrestException e,
    String table,
  ) {
    final m = e.message.toLowerCase();
    final missing =
        m.contains('does not exist') ||
        m.contains('could not find the table') ||
        m.contains('schema cache');
    return missing
        ? ProfileBackendMissingException(
            'Kontrak "$table" tidak dikenal backend: ${e.message}',
            e,
          )
        : ProfileBackendMissingException(
            'Operasi profil gagal: ${e.message}',
            e,
          );
  }
}
