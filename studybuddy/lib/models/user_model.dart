class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final String? phone;
  final String? jenjang;
  final List<String> interestedSubjects;
  final String? parentName;
  final String? parentPhone;
  final DateTime? parentConsentAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
    this.phone,
    this.jenjang,
    this.interestedSubjects = const [],
    this.parentName,
    this.parentPhone,
    this.parentConsentAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    email: map['email'] as String,
    fullName: map['full_name'] as String,
    role: map['role'] as String,
    avatarUrl: map['avatar_url'] as String?,
    fcmToken: map['fcm_token'] as String?,
    createdAt: _parseDateTime(map['created_at']),
    phone: map['phone'] as String?,
    jenjang: map['jenjang'] as String?,
    interestedSubjects: List<String>.from(
      map['interested_subjects'] as List? ?? [],
    ),
    parentName: map['parent_name'] as String?,
    parentPhone: map['parent_phone'] as String?,
    parentConsentAt: map['parent_consent_at'] != null
        ? _parseDateTime(map['parent_consent_at'])
        : null,
  );

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        var normalized = value.replaceFirst(' ', 'T');
        if (RegExp(r'[+-]\d{2}$').hasMatch(normalized)) {
          normalized = '${normalized}:00';
        }
        return DateTime.parse(normalized);
      }
    }
    return DateTime.now();
  }

  bool get isMinor => jenjang == 'SMP';
  bool get hasParentConsent => parentConsentAt != null;
  bool get needsParentConsent => isMinor && !hasParentConsent;

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role,
    'avatar_url': avatarUrl,
    'fcm_token': fcmToken,
    'created_at': createdAt.toIso8601String(),
    'phone': phone,
    'jenjang': jenjang,
    'interested_subjects': interestedSubjects,
    'parent_name': parentName,
    'parent_phone': parentPhone,
    'parent_consent_at': parentConsentAt?.toIso8601String(),
  };

  UserModel copyWith({
    String? fullName,
    Object? avatarUrl = _unset,
    Object? phone = _unset,
    Object? jenjang = _unset,
    Object? interestedSubjects = _unset,
    Object? parentName = _unset,
    Object? parentPhone = _unset,
    Object? parentConsentAt = _unset,
  }) => UserModel(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    role: role,
    avatarUrl: identical(avatarUrl, _unset)
        ? this.avatarUrl
        : avatarUrl as String?,
    fcmToken: fcmToken,
    createdAt: createdAt,
    phone: identical(phone, _unset) ? this.phone : phone as String?,
    jenjang: identical(jenjang, _unset) ? this.jenjang : jenjang as String?,
    interestedSubjects: identical(interestedSubjects, _unset)
        ? this.interestedSubjects
        : interestedSubjects as List<String>,
    parentName: identical(parentName, _unset)
        ? this.parentName
        : parentName as String?,
    parentPhone: identical(parentPhone, _unset)
        ? this.parentPhone
        : parentPhone as String?,
    parentConsentAt: identical(parentConsentAt, _unset)
        ? this.parentConsentAt
        : parentConsentAt as DateTime?,
  );
}

const Object _unset = Object();
