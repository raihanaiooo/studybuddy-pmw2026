enum DocumentRequirement { required, conditional, optional, unclassified }

class TutorDocumentModel {
  final String id;
  final String tutorId;
  final String type;
  final String label;
  final DocumentRequirement requirement;
  final String? fileUrl;
  final String status;
  final String? rejectionNote;

  const TutorDocumentModel({
    required this.id,
    required this.tutorId,
    required this.type,
    required this.label,
    required this.requirement,
    this.fileUrl,
    this.status = 'belum_upload',
    this.rejectionNote,
  });

  factory TutorDocumentModel.fromMap(Map<String, dynamic> map) {
    final jenisDokumen = map['jenis_dokumen'] as String;
    return TutorDocumentModel(
      id: map['id'] as String,
      tutorId: map['tutor_id'] as String,
      type: jenisDokumen,
      label: map['label'] as String? ?? jenisDokumen,
      requirement: _requirementFromJenis(jenisDokumen),
      fileUrl: map['file_url'] as String?,
      status: map['status'] as String? ?? 'belum_upload',
      rejectionNote: map['rejection_note'] as String?,
    );
  }

  /// Klasifikasi requirement berdasarkan SRS FR-PROF-05
  static DocumentRequirement _requirementFromJenis(String jenis) {
    switch (jenis) {
      case 'transkrip':
      case 'kartu_identitas_pelajar':
      case 'kartu_identitas':
      case 'sertifikat_prestasi':
        return DocumentRequirement.required;
      case 'sertifikat_bahasa':
        return DocumentRequirement.conditional;
      default:
        return DocumentRequirement.unclassified;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'tutor_id': tutorId,
    'jenis_dokumen': type,
    'label': label,
    'file_url': fileUrl,
    'status': status,
    'rejection_note': rejectionNote,
  };

  TutorDocumentModel copyWith({
    String? fileUrl,
    String? status,
    String? rejectionNote,
  }) => TutorDocumentModel(
    id: id,
    tutorId: tutorId,
    type: type,
    label: label,
    requirement: requirement,
    fileUrl: fileUrl ?? this.fileUrl,
    status: status ?? this.status,
    rejectionNote: rejectionNote ?? this.rejectionNote,
  );
}
