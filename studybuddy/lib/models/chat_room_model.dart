class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class ChatRoomModel {
  final String id;
  final String customerId;
  final String customerName;
  final String tutorId;
  final String tutorName;
  final String? tutorInitial;
  final String subject;
  final List<ChatMessageModel> messages;
  final DateTime lastActivity;

  const ChatRoomModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.tutorId,
    required this.tutorName,
    this.tutorInitial,
    required this.subject,
    required this.messages,
    required this.lastActivity,
  });

  ChatMessageModel? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get unreadCount => messages.where((m) => !m.isRead).length;
}
