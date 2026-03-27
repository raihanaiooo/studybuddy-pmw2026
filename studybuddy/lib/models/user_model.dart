/// Model data user (customer & tutor)
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'customer' | 'tutor' | 'management'
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    email: map['email'] as String,
    fullName: map['full_name'] as String,
    role: map['role'] as String,
    avatarUrl: map['avatar_url'] as String?,
    fcmToken: map['fcm_token'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role,
    'avatar_url': avatarUrl,
    'fcm_token': fcmToken,
    'created_at': createdAt.toIso8601String(),
  };
}
