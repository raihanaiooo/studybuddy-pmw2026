/// Model data profil tutor beserta statistik
class TutorModel {
  final String id;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String bio;
  final List<String> subjects;
  final double rating;
  final int totalSessions;
  final int totalReviews;
  final bool isOnline;
  final double pricePerHour;
  final String? gmeetLink;
  final String university;
  final double gpa;
  final DateTime? lastSeen;

  // Field verifikasi & profil tambahan (FR-PROF-05/09/12)
  final List<String> extraSkills; // kemampuan di luar mapel utama
  final String verificationStatus; // 'pending' | 'verified' | 'rejected'
  final String? rejectionReason;
  final bool isTutorOfTheMonth;

  const TutorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.bio,
    required this.subjects,
    required this.rating,
    required this.totalSessions,
    required this.totalReviews,
    required this.isOnline,
    required this.pricePerHour,
    this.gmeetLink,
    required this.university,
    required this.gpa,
    this.lastSeen,
    this.extraSkills = const [],
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.isTutorOfTheMonth = false,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map) => TutorModel(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    fullName: map['full_name'] as String,
    avatarUrl: map['avatar_url'] as String?,
    bio: map['bio'] as String? ?? '',
    subjects: List<String>.from(map['subjects'] as List? ?? []),
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    totalSessions: map['total_sessions'] as int? ?? 0,
    totalReviews: map['total_reviews'] as int? ?? 0,
    isOnline: map['is_online'] as bool? ?? false,
    pricePerHour: (map['price_per_hour'] as num?)?.toDouble() ?? 0.0,
    gmeetLink: map['gmeet_link'] as String?,
    university: map['university'] as String? ?? '',
    gpa: (map['gpa'] as num?)?.toDouble() ?? 0.0,
    lastSeen: map['last_seen'] != null
        ? DateTime.parse(map['last_seen'] as String)
        : null,
    extraSkills: List<String>.from(map['kemampuan_lain'] as List? ?? []),
    verificationStatus: map['status_verifikasi'] as String? ?? 'pending',
    rejectionReason: map['rejection_reason'] as String?,
    isTutorOfTheMonth: map['is_tutor_of_the_month'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'subjects': subjects,
    'rating': rating,
    'total_sessions': totalSessions,
    'total_reviews': totalReviews,
    'is_online': isOnline,
    'price_per_hour': pricePerHour,
    'gmeet_link': gmeetLink,
    'university': university,
    'gpa': gpa,
    'last_seen': lastSeen?.toIso8601String(),
    'kemampuan_lain': extraSkills,
    'status_verifikasi': verificationStatus,
    'rejection_reason': rejectionReason,
    'is_tutor_of_the_month': isTutorOfTheMonth,
  };
}
