import '../models/chat_message_model.dart';

abstract class ChatRepository {
  /// Ambil semua pesan dalam satu sesi
  Future<List<ChatMessageModel>> fetchMessages(String sessionId);

  /// Kirim pesan teks
  Future<ChatMessageModel> sendTextMessage({
    required String sessionId,
    required String senderId,
    required String content,
  });

  /// Kirim pesan dengan attachment
  Future<ChatMessageModel> sendAttachmentMessage({
    required String sessionId,
    required String senderId,
    required String content,
    required ChatMessageType type,
    required String fileName,
    required List<int> fileBytes,
  });

  /// Subscribe realtime untuk sesi tertentu
  void subscribeToSession(
    String sessionId,
    void Function(ChatMessageModel) onNewMessage,
  );

  /// Unsubscribe
  Future<void> unsubscribe();
}

class ChatBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const ChatBackendMissingException(this.message, [this.cause]);

  @override
  String toString() => 'ChatBackendMissingException: $message';
}
