import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat_room_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(ChatController chatCtrl, String roomId) {
    if (_messageCtrl.text.trim().isEmpty) return;
    final text = _messageCtrl.text.trim();
    _messageCtrl.clear();

    chatCtrl.sendMessage(roomId, text);
    _scrollToBottom();

    final room = chatCtrl.chatRooms.firstWhereOrNull((r) => r.id == roomId);
    if (room == null) return;

    final auth = Get.find<AuthController>();
    final isCustomer = auth.currentUser.value?.role == 'customer';

    if (isCustomer) {
      final tutorId = room.tutorId;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isTyping = true);
        _scrollToBottom();
      });
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _isTyping = false);
          chatCtrl.sendMessage(roomId, _getAutoReply(text),
              senderId: tutorId);
          _scrollToBottom();
        }
      });
    }
  }

  String _getAutoReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('jadwal') || lower.contains('kapan')) {
      return 'Jadwal bisa dicek di tab Jadwal ya. Kalau mau booking sesi baru, tinggal buka profil tutor!';
    }
    if (lower.contains('terima kasih') || lower.contains('makasih')) {
      return 'Sama-sama! Semangat belajarnya 💪';
    }
    if (lower.contains('soal') || lower.contains('tugas')) {
      return 'Oke, coba kirimkan fotonya. Nanti aku bantu penjelasannya.';
    }
    return 'Baik, noted ya. Ada yang lain? 😊';
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final auth = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>?;
    final roomId = args?['roomId'] as String? ?? '';

    final room =
        chatCtrl.chatRooms.firstWhereOrNull((r) => r.id == roomId);

    if (room == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.blueDark,
          foregroundColor: Colors.white,
          title: const Text('Chat'),
        ),
        body: const Center(child: Text('Percakapan tidak ditemukan')),
      );
    }

    final currentUserId = auth.currentUser.value?.id ?? 'c_demo';
    final otherName = chatCtrl.getOtherName(room);
    final otherInitial = chatCtrl.getOtherInitial(room) ?? '?';
    final messages = room.messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(context, otherName, otherInitial, room.subject),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length + 1 + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == 0) return _buildDateDivider(messages);
                final msgIndex = i - 1;
                if (msgIndex < messages.length) {
                  final msg = messages[msgIndex];
                  final isMe = msg.senderId == currentUserId;
                  return _buildChatBubble(msg, isMe, otherInitial);
                }
                return _buildTypingIndicator(otherInitial);
              },
            ),
          ),
          _buildMessageInput(chatCtrl, room.id),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String name, String initial, String subject) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3C), Color(0xFF2E3A6E), Color(0xFF1A5EAA)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF6BB5FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online · $subject',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(List<ChatMessageModel> messages) {
    if (messages.isEmpty) return const SizedBox.shrink();
    final date = messages.last.timestamp;
    String label;
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) {
      label = 'Hari ini';
    } else if (diff == 1) {
      label = 'Kemarin';
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
      ChatMessageModel msg, bool isMe, String otherInitial) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 36,
              right: isMe ? 0 : 0,
            ),
            child: Text(
              DateFormat('HH:mm').format(msg.timestamp),
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 4),
          isMe
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.message,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, Color(0xFF6BB5FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        otherInitial.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.message,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(String otherInitial) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF6BB5FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              otherInitial.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDot(delayMs: 0),
                const SizedBox(width: 4),
                _BouncingDot(delayMs: 200),
                const SizedBox(width: 4),
                _BouncingDot(delayMs: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatController chatCtrl, String roomId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.attach_file_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageCtrl,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
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
                style: AppTextStyles.body,
                maxLines: 3,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(chatCtrl, roomId),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(chatCtrl, roomId),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delayMs;
  const _BouncingDot({required this.delayMs});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        final dy = -4 * (0.5 - (t - 0.5).abs()).abs();
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.textLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
