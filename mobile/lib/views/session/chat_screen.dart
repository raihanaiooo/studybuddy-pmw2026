import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/chat_message_model.dart';
import '../../models/session_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final sessionCtrl = Get.find<SessionController>();
    final session = sessionCtrl.currentSession.value;
    final isActive = ChatController.isChatActive(session);

    // Load chat kalau belum
    if (session != null &&
        chatCtrl.messages.isEmpty &&
        !chatCtrl.isLoading.value) {
      chatCtrl.loadForSession(session.id);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat Sesi', style: TextStyle(fontSize: 16)),
            Text(
              isActive ? 'Aktif' : 'Chat ditutup',
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.onlineGreen : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isActive) _closedBanner(),
          Expanded(
            child: Obx(() {
              if (chatCtrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }
              if (chatCtrl.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      chatCtrl.errorMessage.value,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (chatCtrl.messages.isEmpty) {
                return _emptyState();
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: chatCtrl.messages.length,
                itemBuilder: (_, i) {
                  final msg = chatCtrl.messages[i];
                  final isMe = chatCtrl.isMyMessage(msg);
                  return _chatBubble(msg, isMe);
                },
              );
            }),
          ),
          _inputArea(chatCtrl, isActive),
        ],
      ),
    );
  }

  Widget _closedBanner() => Container(
    padding: const EdgeInsets.all(12),
    color: AppColors.primaryYellow.withOpacity(0.12),
    child: Row(
      children: [
        const Icon(
          Icons.lock_outline,
          color: AppColors.primaryYellow,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Chat hanya aktif selama sesi berlangsung (±15 menit).',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 56,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 12),
          Text('Belum ada pesan', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 6),
          Text(
            'Mulai percakapan dengan mengirim materi atau koordinasi.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _chatBubble(ChatMessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('HH:mm').format(msg.createdAt),
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _bubbleContent(msg, isMe),
          ),
        ],
      ),
    );
  }

  Widget _bubbleContent(ChatMessageModel msg, bool isMe) {
    final textColor = isMe ? Colors.white : AppColors.textPrimary;

    if (msg.messageType == ChatMessageType.image && msg.fileUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              msg.fileUrl!,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          if (msg.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(msg.content, style: TextStyle(color: textColor)),
          ],
        ],
      );
    }

    if (msg.messageType == ChatMessageType.file && msg.fileUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: isMe ? Colors.white : AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  msg.fileName ?? 'File',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (msg.fileSize != null) ...[
            const SizedBox(height: 4),
            Text(
              '${(msg.fileSize! / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : AppColors.textLight,
              ),
            ),
          ],
          if (msg.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(msg.content, style: TextStyle(color: textColor)),
          ],
        ],
      );
    }

    return Text(
      msg.content,
      style: AppTextStyles.body.copyWith(color: textColor),
    );
  }

  Widget _inputArea(ChatController chatCtrl, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: isActive ? () => _pickFile(chatCtrl) : null,
              icon: Icon(
                Icons.attach_file_rounded,
                color: isActive ? AppColors.primaryBlue : AppColors.textLight,
              ),
              tooltip: 'Lampirkan file',
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageCtrl,
                  enabled: isActive,
                  decoration: InputDecoration(
                    hintText: isActive ? 'Ketik pesan...' : 'Chat ditutup',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textLight,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => IconButton(
                onPressed: isActive && !chatCtrl.isSending.value
                    ? () {
                        final text = _messageCtrl.text;
                        if (text.trim().isEmpty) return;
                        _messageCtrl.clear();
                        chatCtrl.sendText(text);
                        _scrollToBottom();
                      }
                    : null,
                icon: chatCtrl.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: isActive
                            ? AppColors.primaryBlue
                            : AppColors.textLight,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(ChatController chatCtrl) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'zip',
      ],
    );

    if (result.isEmpty) return;
    final picked = result.single;
    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(ext);

    await chatCtrl.sendAttachment(
      fileName: picked.name,
      fileBytes: bytes,
      type: isImage ? ChatMessageType.image : ChatMessageType.file,
      content: _messageCtrl.text.trim(),
    );
    _messageCtrl.clear();
    _scrollToBottom();
  }
}
