class TutorModel {
  final String id;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String bio;
  final List<String> subjects;
  final List<String> jenjangDiajar;
  final double rating;
  final int totalSessions;
  final int totalReviews;
  final bool isOnline;
  final double pricePerHour;
  final String? gmeetLink;
  final String university;
  final double gpa;
  final DateTime? lastSeen;
  final String verificationStatus;
  final String? verificationNote;

  const TutorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.bio,
    required this.subjects,
    this.jenjangDiajar = const [],
    required this.rating,
    required this.totalSessions,
    required this.totalReviews,
    required this.isOnline,
    required this.pricePerHour,
    this.gmeetLink,
    required this.university,
    required this.gpa,
    this.lastSeen,
    this.verificationStatus = 'pending',
    this.verificationNote,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map) => TutorModel(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    fullName: map['full_name'] as String,
    avatarUrl: map['avatar_url'] as String?,
    bio: map['bio'] as String? ?? '',
    subjects: List<String>.from(map['subjects'] as List? ?? []),
    jenjangDiajar: List<String>.from(map['jenjang_diajar'] as List? ?? []),
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    totalSessions: map['total_sessions'] as int? ?? 0,
    totalReviews: map['total_reviews'] as int? ?? 0,
    isOnline: map['is_online'] as bool? ?? false,
    pricePerHour: (map['price_per_hour'] as num?)?.toDouble() ?? 0.0,
    gmeetLink: map['gmeet_link'] as String?,
    university: map['university'] as String? ?? '',
    gpa: (map['gpa'] as num?)?.toDouble() ?? 0.0,
    lastSeen: map['last_seen'] != null
        ? _parseDateTime(map['last_seen'])
        : null,
    verificationStatus: map['verification_status'] as String? ?? 'pending',
    verificationNote: map['verification_note'] as String?,
  );

  static DateTime _parseDateTime(dynamic value) {
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'subjects': subjects,
    'jenjang_diajar': jenjangDiajar,
    'rating': rating,
    'total_sessions': totalSessions,
    'total_reviews': totalReviews,
    'is_online': isOnline,
    'price_per_hour': pricePerHour,
    'gmeet_link': gmeetLink,
    'university': university,
    'gpa': gpa,
    'last_seen': lastSeen?.toIso8601String(),
    'verification_status': verificationStatus,
    'verification_note': verificationNote,
  };
}
