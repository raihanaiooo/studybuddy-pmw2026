/// Model ulasan customer setelah sesi selesai
class ReviewModel {
  final String id;
  final String sessionId;
  final String customerId;
  final String tutorId;
  final int rating; // 1-5
  final String comment;
  final String subject;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.sessionId,
    required this.customerId,
    required this.tutorId,
    required this.rating,
    required this.comment,
    required this.subject,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id: map['id'] as String,
    sessionId: map['session_id'] as String,
    customerId: map['customer_id'] as String,
    tutorId: map['tutor_id'] as String,
    rating: map['rating'] as int,
    comment: map['comment'] as String? ?? '',
    subject: map['subject'] as String? ?? '',
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
