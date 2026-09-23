/// Jenis dokumen verifikasi Tutor (FR-PROF-06/07/08)
///
/// Katalog enam dokumen lama klien KONFLIK dengan SRS FR-PROF-05 (UTBK & CV
/// tidak ada di SRS; sertifikat prestasi ada di set wajib SRS tapi dulu
/// ditandai opsional) — lihat D-17/C-DOC-07 yang masih terbuka.
/// [DocumentRequirement.unclassified] adalah nilai JUJUR untuk "klasifikasi
/// belum bisa diverifikasi" — jangan pernah menggantinya dengan tebakan.
enum DocumentRequirement { required, conditional, optional, unclassified }

/// Model dokumen yang diunggah Tutor untuk proses verifikasi
class TutorDocumentModel {
  final String id;
  final String tutorId;
  final String type; // mis. 'transkrip', 'ktm', 'sertifikat_bahasa', dst
  final String label;
  final DocumentRequirement requirement;
  final String? fileUrl;
  final String status; // 'belum_upload' | 'menunggu' | 'terverifikasi' | 'ditolak'

  const TutorDocumentModel({
    required this.id,
    required this.tutorId,
    required this.type,
    required this.label,
    required this.requirement,
    this.fileUrl,
    this.status = 'belum_upload',
  });

  factory TutorDocumentModel.fromMap(Map<String, dynamic> map) =>
      TutorDocumentModel(
        id: map['id'] as String,
        tutorId: map['tutor_id'] as String,
        type: map['jenis_dokumen'] as String,
        label: map['label'] as String? ?? map['jenis_dokumen'] as String,
        requirement: DocumentRequirement.values.firstWhere(
          (r) => r.name == map['requirement'],
          // Tidak menebak: nilai yang tidak dikenal dilaporkan apa adanya.
          orElse: () => DocumentRequirement.unclassified,
        ),
        fileUrl: map['file_url'] as String?,
        status: map['status'] as String? ?? 'belum_upload',
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tutor_id': tutorId,
    'jenis_dokumen': type,
    'label': label,
    'requirement': requirement.name,
    'file_url': fileUrl,
    'status': status,
  };

  TutorDocumentModel copyWith({String? fileUrl, String? status}) =>
      TutorDocumentModel(
        id: id,
        tutorId: tutorId,
        type: type,
        label: label,
        requirement: requirement,
        fileUrl: fileUrl ?? this.fileUrl,
        status: status ?? this.status,
      );
}
