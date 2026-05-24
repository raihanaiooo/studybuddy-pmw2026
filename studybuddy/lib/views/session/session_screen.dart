import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/booking_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
// UI-only prototype: no mock persistence

/// Session screen: chat interface dengan timer sesi
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late TextEditingController _messageCtrl;
  late ScrollController _scrollCtrl;
  late List<ChatMessage> _messages;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _messageCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _messages = [
      ChatMessage(
        sender: 'Arif Rahmat, S.Si',
        message:
            'Halo Rania! Kita mulai sesi Fisika hari ini ya. Kamu mau fokus ke materi apa dulu?',
        isFromTutor: true,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        sender: 'You',
        message:
            'Kak, aku mau bahas Hukum Newton dulu dong, soal UTS kemarin banyak yang salah 😅',
        isFromTutor: false,
        time: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];

    final booking = Get.arguments as BookingModel?;
    if (booking != null) {
      Get.find<SessionController>().startSession(
        booking.id,
        booking.sessionType == 'video' ? null : null,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

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

  void _sendMessage() {
    if (_messageCtrl.text.trim().isEmpty) return;
    final text = _messageCtrl.text.trim();

    // Add locally and persist to mock if available
    final chat = ChatMessage(
      sender: 'You',
      message: text,
      isFromTutor: false,
      time: DateTime.now(),
    );

    setState(() => _messages.add(chat));
    _messageCtrl.clear();
    _scrollToBottom();

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'You',
          message: text,
          isFromTutor: false,
          time: DateTime.now(),
        ),
      );
    });

    _messageCtrl.clear();
    _scrollToBottom();

    // Simulated tutor response (UI-only prototype, no persistence)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              sender: 'Arif Rahmat, S.Si',
              message:
                  'Oke! Ini diagram Hukum Newton II yang aku buat. Perhatikan arah vektor gaya ya.',
              isFromTutor: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    final auth = Get.find<AuthController>();
    final booking = Get.arguments as BookingModel?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header dengan timer
          _buildSessionHeader(ctrl, booking, auth),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildChatBubble(_messages[i]),
            ),
          ),

          // Input field
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSessionHeader(
    SessionController ctrl,
    BookingModel? booking,
    AuthController auth,
  ) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        child: Column(
          children: [
            // Prototype label
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryYellow.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Prototype UI',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryYellow,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tutor info & timer row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tutor avatar & name
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arif Rahmat, S.Si',
                              style: AppTextStyles.heading3.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.onlineGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Online · Fisika & Matematika',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Pause button
                GestureDetector(
                  onTap: () => setState(() => _isPaused = !_isPaused),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Session info card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SESI BERJALAN',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          _isPaused ? '⏸ JEDA' : ctrl.timerFormatted,
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sisa 22 menit 36 detik',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.62,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Packet & progress info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('60', 'Durasi (mnt)'),
                _buildInfoChip(
                  'Intensif',
                  'Paket',
                  color: AppColors.primaryYellow,
                ),
                _buildInfoChip(
                  'Sesi 1/3',
                  'Progress',
                  color: AppColors.primaryYellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String value, String label, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color ?? AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isFromTutor = msg.isFromTutor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isFromTutor
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // Time (optional)
          Text(
            DateFormat('HH:mm').format(msg.time),
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isFromTutor ? Colors.white : AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isFromTutor ? 0 : 16),
                bottomRight: Radius.circular(isFromTutor ? 16 : 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.message,
              style: AppTextStyles.body.copyWith(
                color: isFromTutor ? AppColors.textPrimary : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Icon buttons
          GestureDetector(
            onTap: () {
              // File/image picker
            },
            child: Icon(
              Icons.attach_file_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
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

/// Model untuk chat message
class ChatMessage {
  final String sender;
  final String message;
  final bool isFromTutor;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isFromTutor,
    required this.time,
  });
}
