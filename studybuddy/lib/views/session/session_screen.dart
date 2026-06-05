import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/customer/session_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/booking_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../mock/mock_data.dart';
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
  bool _isTyping = false;

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
      // Ambil GMeet link dari tutor jika sesi video
      String? gmeetLink;
      if (booking.sessionType == 'video') {
        final tutor = mockTutors.firstWhereOrNull((t) => t.id == booking.tutorId);
        gmeetLink = tutor?.gmeetLink;
      }
      Get.find<SessionController>().startSession(
        booking.id,
        gmeetLink,
        booking: booking,
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

    setState(() {
      _messages.add(ChatMessage(
        sender: 'You',
        message: text,
        isFromTutor: false,
        time: DateTime.now(),
      ));
    });
    _messageCtrl.clear();
    _scrollToBottom();

    // Simulated tutor typing + response (UI-only prototype)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isTyping = true);
        _scrollToBottom();
      }
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
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
          // White chat header bar
          _buildChatHeader(),

          // Header dengan timer
          _buildSessionHeader(ctrl, booking, auth),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + 1 + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == 0) return _buildDateDivider();
                final msgIndex = i - 1;
                if (msgIndex < _messages.length) {
                  return _buildChatBubble(_messages[msgIndex]);
                }
                return _buildTypingIndicator();
              },
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
                    color: AppColors.primaryYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryYellow.withValues(alpha: 0.2),
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
          // Time
          Text(
            DateFormat('HH:mm').format(msg.time),
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          // Message row with optional avatar
          isFromTutor
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.blueLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'A',
                        style: TextStyle(
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.message,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1A1F3C),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Tutor avatar with online dot
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.blueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.onlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Name & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arif Rahmat, S.Si',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '● Online · Fisika & Matematika',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Three-dot menu
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Hari ini, 13.00',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.blueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBounceDot(0),
                const SizedBox(width: 4),
                _buildBounceDot(200),
                const SizedBox(width: 4),
                _buildBounceDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBounceDot(int delayMs) {
    return _BouncingDot(delayMs: delayMs);
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
