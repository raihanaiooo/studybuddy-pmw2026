/// Model data user (customer & tutor)
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'customer' | 'tutor' | 'management'
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;

  // Field profil Buddy (FR-PROF-01) — opsional, menunggu kontrak BE final
  // untuk kolom ini di tabel users (lihat SRS 4.1).
  final String? phone;
  final int? age;
  final String? gradeLevel; // jenjang: SMP/SMA/Mahasiswa/Lulusan/Umum
  final String? school; // asal sekolah/kampus
  final List<String> interestedSubjects;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
    this.phone,
    this.age,
    this.gradeLevel,
    this.school,
    this.interestedSubjects = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    email: map['email'] as String,
    fullName: map['full_name'] as String,
    role: map['role'] as String,
    avatarUrl: map['avatar_url'] as String?,
    fcmToken: map['fcm_token'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    phone: map['phone'] as String?,
    age: map['usia'] as int?,
    gradeLevel: map['kelas'] as String?,
    school: map['asal_sekolah'] as String?,
    interestedSubjects: List<String>.from(
      map['mata_pelajaran_diminati'] as List? ?? [],
    ),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role,
    'avatar_url': avatarUrl,
    'fcm_token': fcmToken,
    'created_at': createdAt.toIso8601String(),
    'phone': phone,
    'usia': age,
    'kelas': gradeLevel,
    'asal_sekolah': school,
    'mata_pelajaran_diminati': interestedSubjects,
  };

  UserModel copyWith({
    String? fullName,
    String? phone,
    int? age,
    String? gradeLevel,
    String? school,
    List<String>? interestedSubjects,
  }) => UserModel(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    role: role,
    avatarUrl: avatarUrl,
    fcmToken: fcmToken,
    createdAt: createdAt,
    phone: phone ?? this.phone,
    age: age ?? this.age,
    gradeLevel: gradeLevel ?? this.gradeLevel,
    school: school ?? this.school,
    interestedSubjects: interestedSubjects ?? this.interestedSubjects,
  );
}
