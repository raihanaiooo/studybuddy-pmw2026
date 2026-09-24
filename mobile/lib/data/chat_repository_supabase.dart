import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../domain/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositorySupabase implements ChatRepository {
  static const String _table = 'chat_messages';
  static const String _bucket = 'chat_attachments';

  RealtimeChannel? _channel;
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<ChatMessageModel>> fetchMessages(String sessionId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
      return (data as List)
          .map((e) => ChatMessageModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ChatBackendMissingException('Gagal memuat pesan: ${e.message}', e);
    }
  }

  @override
  Future<ChatMessageModel> sendTextMessage({
    required String sessionId,
    required String senderId,
    required String content,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .insert({
            'session_id': sessionId,
            'sender_id': senderId,
            'content': content,
            'message_type': 'text',
          })
          .select()
          .single();
      return ChatMessageModel.fromMap(data);
    } on PostgrestException catch (e) {
      throw ChatBackendMissingException(
        'Gagal mengirim pesan: ${e.message}',
        e,
      );
    }
  }

  @override
  Future<ChatMessageModel> sendAttachmentMessage({
    required String sessionId,
    required String senderId,
    required String content,
    required ChatMessageType type,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$sessionId/$senderId-$timestamp.$ext';

      // Upload file
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            storagePath,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(upsert: false),
          );

      final fileUrl = _client.storage.from(_bucket).getPublicUrl(storagePath);

      // Simpan metadata
      final data = await _client
          .from(_table)
          .insert({
            'session_id': sessionId,
            'sender_id': senderId,
            'content': content,
            'message_type': type == ChatMessageType.image ? 'image' : 'file',
            'file_url': fileUrl,
            'file_name': fileName,
            'file_size': fileBytes.length,
          })
          .select()
          .single();
      return ChatMessageModel.fromMap(data);
    } on StorageException catch (e) {
      throw ChatBackendMissingException('Gagal upload file: ${e.message}', e);
    } on PostgrestException catch (e) {
      throw ChatBackendMissingException(
        'Gagal menyimpan pesan: ${e.message}',
        e,
      );
    }
  }

  @override
  void subscribeToSession(
    String sessionId,
    void Function(ChatMessageModel) onNewMessage,
  ) {
    // Unsubscribe dulu kalau ada channel lama
    _channel?.unsubscribe();

    _channel = _client
        .channel('chat_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              final message = ChatMessageModel.fromMap(newRecord);
              onNewMessage(message);
            } catch (e) {
              print('ChatRepository.subscribeToSession parse error: $e');
            }
          },
        )
        .subscribe();
  }

  @override
  Future<void> unsubscribe() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
}
