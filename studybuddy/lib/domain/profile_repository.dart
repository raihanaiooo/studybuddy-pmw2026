abstract class ProfileRepository {
  Future<BuddyProfileData> fetchBuddyProfile(String userId);
  Future<void> updateBuddyProfile(String userId, BuddyProfilePatch patch);
  Future<TutorProfileData> fetchMyTutorProfile(String userId);
  Future<void> updateTutorProfile(String tutorId, TutorProfilePatch patch);
  Future<List<TutorDocumentRecord>> fetchMyTutorDocuments(String tutorId);
}

class BuddyProfileData {
  final String? fullName;
  final String? phone;
  final String? jenjang;
  final List<String> interestedSubjects;

  const BuddyProfileData({
    this.fullName,
    this.phone,
    this.jenjang,
    this.interestedSubjects = const [],
  });
}

class TutorProfileData {
  final String id;
  final String userId;
  final String fullName;
  final String bio;
  final List<String> subjects;
  final List<String> jenjangDiajar;
  final String? verificationStatus;
  final String? verificationNote;

  const TutorProfileData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.subjects,
    this.jenjangDiajar = const [],
    this.verificationStatus,
    this.verificationNote,
  });
}

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

const Object _unset = Object();

class BuddyProfilePatch {
  BuddyProfilePatch({
    Object? fullName = _unset,
    Object? phone = _unset,
    Object? jenjang = _unset,
    this.interestedSubjects,
  }) : _fullName = fullName,
       _phone = phone,
       _jenjang = jenjang;

  final Object? _fullName;
  final Object? _phone;
  final Object? _jenjang;
  final List<String>? interestedSubjects;

  bool get hasFullName => !identical(_fullName, _unset);
  String? get fullName => hasFullName ? _fullName as String? : null;

  bool get hasPhone => !identical(_phone, _unset);
  String? get phone => hasPhone ? _phone as String? : null;

  bool get hasJenjang => !identical(_jenjang, _unset);
  String? get jenjang => hasJenjang ? _jenjang as String? : null;

  bool get isEmpty =>
      !hasFullName && !hasPhone && !hasJenjang && interestedSubjects == null;
}

class TutorProfilePatch {
  final String? bio;
  final List<String>? subjects;
  final List<String>? jenjangDiajar;

  const TutorProfilePatch({this.bio, this.subjects, this.jenjangDiajar});

  bool get isEmpty => bio == null && subjects == null && jenjangDiajar == null;
}

enum SrsDocumentType {
  transkrip('transkrip', 'Transkrip Nilai', 'Wajib'),
  kartuIdentitasPelajar(
    'kartu_identitas_pelajar',
    'KTM / Kartu Tanda Pelajar',
    'Wajib',
  ),
  sertifikatPrestasi('sertifikat_prestasi', 'Sertifikat Prestasi', 'Wajib'),
  sertifikatBahasa(
    'sertifikat_bahasa',
    'Sertifikat Bahasa',
    'Bersyarat — khusus Tutor kelas bahasa asing',
  );

  const SrsDocumentType(this.jenis, this.label, this.srsRequirementText);

  final String jenis;
  final String label;
  final String srsRequirementText;

  static SrsDocumentType? byJenis(String jenis) {
    for (final t in SrsDocumentType.values) {
      if (t.jenis == jenis) return t;
    }
    return null;
  }
}

class ProfileBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const ProfileBackendMissingException(this.message, [this.cause]);

  @override
  String toString() =>
      'ProfileBackendMissingException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
